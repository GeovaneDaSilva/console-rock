# :nodoc
class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception, prepend: true

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :sample_transactions_for_scout_apm
  after_action :set_time_zone, if: :devise_controller?

  helper_method :current_provider, :current_account, :rendered_for_pdf?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email name new_provider_name accept_tos])
    devise_parameter_sanitizer.permit(
      :account_update, keys: %i[email first_name last_name timezone accept_tos]
    )
  end

  def current_provider
    nil
  end

  def current_account
    nil
  end

  def set_time_zone
    return if !resource&.persisted? || resource.changed? || cookies[:timezone].nil?

    resource.update(timezone: rails_timezone)
    cookies.delete :timezone
  end

  def rails_timezone
    ActiveSupport::TimeZone::MAPPING.select { |_k, v| v == cookies[:timezone] }.keys.first
  end

  def after_sign_in_path_for(resource_or_scope)
    return new_customer_url if User === resource_or_scope && resource_or_scope.new_provider_name.present?

    stored_location_for(resource_or_scope) || signed_in_root_path(resource_or_scope)
  end

  def rendered_for_pdf?
    @rendered_for_pdf ||= params[:pdf].present?
  end

  def append_info_to_payload(payload)
    super
    payload[:request] = request if respond_to?(:request) && request.present?
    payload[:user] = current_user if current_user.present?
    payload[:account] = current_account if current_account.present?
    payload[:provider] = current_provider if current_provider.present?
  end

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    locale = request.host.split(".").second
    I18n.available_locales.map(&:to_s).include?(locale) ? locale : nil
  end

  def apm_sample_rate
    # sample 50% of transactions
    0.5
  end

  def sample_transactions_for_scout_apm
    return unless Rails.env.production?

    ScoutApm::Transaction.ignore! if rand > apm_sample_rate
  end
end
