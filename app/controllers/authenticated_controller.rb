# Base controller for all authenticated actions
class AuthenticatedController < ApplicationController
  include BillingNotifiable

  before_action :authenticate_user!, unless: :optional_authentication?
  before_action :switch_accounts!
  before_action :force_2fa, unless: :skip_redirects?
  before_action :onboard!, unless: :skip_redirects?
  before_action :credit_card_required!, unless: :skip_redirects?

  after_action :verify_authorized, unless: :optional_authentication?
  after_action :update_recent_accounts!, if: :current_account

  around_action :user_timezone

  helper_method :account_path, :current_role, :current_account, :current_user_role, :recent_accounts

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_provider
    @current_provider ||= find_current_provider
  end

  def current_role
    @current_role ||= find_current_role
  end

  def current_user_role
    @current_user_role || UserRole.where(
      user: current_user, account: [current_account&.self_and_ancestors]
    ).first
  end

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id])
    Raven.extra_context(
      params: params.to_unsafe_h, url: request.url, account_id: session[:account_id],
      account_name: current_account&.name
    )
  end

  def switch_accounts!
    id = params[:switch_account_id]
    return if id.blank?
    return if !current_user.admin? && !current_user.account_ids.include?(id)

    session[:account_id] = id
    @current_account     = nil
    @current_user_role   = nil
  end

  def recent_accounts
    @recent_accounts ||= session[:recent_accounts].to_a.uniq
  end

  def onboard!
    return unless current_provider && current_account && !current_account.completed?

    redirect_to Onboarding::Router.new(
      current_account
    ).call
  end

  def current_account
    @current_account ||= if session[:account_id]
                           Account.find(session[:account_id])
                         else
                           UserRole.where(user: current_user).includes(:account).first&.account
                         end
  rescue ActiveRecord::RecordNotFound
    session[:account_id] = nil
  end

  def find_current_provider
    provider = if current_account&.provider?
                 current_account
               elsif current_account&.customer?
                 current_account.provider
               end

    return nil if !provider || !policy(provider).make_current?

    provider
  end

  def find_current_role
    current_user.admin_role || current_user_role&.role
  end

  def user_timezone(&block)
    Time.use_zone(current_user&.timezone, &block)
  end

  def optional_authentication?
    false
  end

  def skip_redirects?
    devise_controller? || skip_onboarding_redirect? || skip_credit_card_required?
  end

  def skip_onboarding_redirect?
    current_user&.admin? || false
  end

  def credit_card_required!
    return if current_user&.admin?
    return if current_account.nil?
    return unless current_account.needs_credit_card?
    return unless policy(current_account).can_modify_plan?

    flash[:error] = "Please enter a credit card before continuing"
    redirect_to new_account_credit_card_path(current_account)
  end

  def skip_credit_card_required?
    false
  end

  def update_recent_accounts!
    id = session[:account_id]
    recent_accounts = session[:recent_accounts] || []

    return if id.nil?

    recent_accounts.delete(id)
    recent_accounts.unshift(id)

    session[:recent_accounts] = recent_accounts.uniq.take(6).compact
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    logger.warn(
      "Unauthorized access attemtped! \n
      #{policy_name}.#{exception.query} \n
      by User ##{current_user.id} \n
      from #{request.referer}"
    )

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referer || root_path)
  end

  def account_path(account, *opts)
    if account.customer?
      customer_path(account, *opts)
    elsif account.provider?
      provider_path(account, *opts)
    end
  end

  def force_2fa
    if force_2fa_account?
      session[:require_two_factor] = true
      redirect_to qr_path
    else
      session.delete(:require_two_factor)
    end
  end

  def direct_accounts_with_2fa_enabled?
    key = "v1/direct_accounts_with_2fa_enabled/User:#{current_user.id}"
    Rails.cache.fetch(key, expires_in: 1.hour) do
      direct_accounts_with_2fa_enabled = Setting.joins(:account)
                                                .two_factor_accounts
                                                .merge(Account.where(id: current_user.accounts))
      !direct_accounts_with_2fa_enabled.empty?
    end
  end

  def parent_accounts_with_sub_account_2fa_enabled?
    key = "v1/parent_sub_accounts_with_2fa_enabled/User:#{current_user.id}"
    Rails.cache.fetch(key, expires_in: 1.hour) do
      all_user_account_paths = current_user.accounts.map(&:path)
      relation = Account.none
      all_user_account_paths.each do |path|
        relation = relation.or(Account.where("path @> ?", path))
      end

      ascendant_accounts = relation.reject { |account| all_user_account_paths.include?(account.path) }
      ascendant_account_ids = ascendant_accounts.map(&:id)
      ancestors_with_sub_account_2fa_enabled = Setting.joins(:account)
                                                      .two_factor_sub_accounts
                                                      .merge(Account.where(id: ascendant_account_ids))
      !ancestors_with_sub_account_2fa_enabled.empty?
    end
  end

  def force_2fa_account?
    return true if session[:require_two_factor]
    return false if current_user.otp_backup_codes?
    return true if direct_accounts_with_2fa_enabled?
    return true if parent_accounts_with_sub_account_2fa_enabled?

    false
  end
end
