# :nodoc
class ProvidersController < AuthenticatedController
  before_action :find_provider, only: %i[show edit update destroy]

  helper_method :sla

  def index
    skip_authorization
    @providers = policy_scope(Provider).roots

    redirect_to new_provider_path unless @providers.size.positive?
  end

  def new
    @provider = Provider.new
    authorize(@provider)

    return redirect_to new_administration_provider_path if current_user.admin_role && current_account.blank?
  end

  def create
    build_provider

    authorize(@provider, :new?)

    if @provider.save
      if !current_user.omnipotent?
        Subscriptions::Email.create(
          account: @provider, event_types: [:malicious_indicator], email_address: current_user.email
        )
      end

      ServiceRunnerJob.perform_later("Braintree::CustomerBuilder", @provider) if @provider.billing_account?

      session[:account_id] = @provider.id

      flash[:notice] = "Successfully added the provider"

      redirect_to provider_created_path
    else
      render "new"
    end
  end

  def show
    authorize(@provider)

    @email_subscription = Subscriptions::Email.find_or_initialize_by(account: @provider)
    @api_key = ApiKey.find_or_initialize_by(account: @provider)

    if policy(@provider).can_modify_plan?
      @plans = if current_user.admin?
                 policy_scope(Plan)
                   &.includes(:apps)
                   &.order("plan_type, price_per_frequency_cents ASC, price_per_device_overage_cents ASC")
               else
                 policy_scope(Plan)
                   .where(plan_type: plan_type)
                   .or(Plan.where(id: @provider.billing_account.plan_id))
                   &.includes(:apps)
                   &.order("price_per_frequency_cents ASC, price_per_device_overage_cents ASC")
               end
      @charges = @provider.charges.includes(:plan).order("created_at desc")
    end
  end

  def update
    authorize(@provider)

    was_actionable_past_due = @provider.actionable_past_due?
    generate_api_key unless params[:api_key].nil?

    if @provider.update(provider_params)
      ServiceRunnerJob.perform_later("Braintree::CustomerBuilder", @provider) if @provider.billing_account?
      broadcast_check_for_hunts! if was_actionable_past_due
      broadcast_check_for_apps! if was_actionable_past_due

      @provider.setting.broadcast_changes!
      all_descendant_users.update_all(session_timeout: @provider.setting.user_session_timeout)

      flash[:notice] = "Successfully updated the provider"
    else
      flash[:error] = "Problem updating provider settings"
    end
    redirect_to provider_path(@provider, anchor: params[:tab])
  end

  # rubocop:disable Layout/LineLength
  def extend_trial_days
    target = current_account
    if target.billing_account.plan.nil?
      return flash[:error] = "You must have a billing account to complete this action"
    end

    authorize(target, :can_extend_trial_for_sub_account?)

    if target.update(paid_thru: new_paid_thru_date)
      flash[:notice] = "Successfully extended trial duration. Trial end date is: #{target.paid_thru}"
    else
      flash[:error] =
        "Unable to extend this customer's trial. Please verify you have the right user role to complete this action."
    end
    redirect_to provider_path(target.billing_account, anchor: "billing")
  end
  # rubocop:enable Layout/LineLength

  private

  def new_paid_thru_date
    current_account.paid_thru.to_date + extend_trial_days_params["extend_days"].to_i.days
  end

  def all_descendant_users
    User.joins(:roles).where(user_roles: { account_id: @provider.self_and_all_descendants.pluck(:id) })
  end

  # this assumes you will not mix plan types in the same account (e.g. both pax8 and not, barracuda and pax8)
  def plan_type
    @provider.billing_account.plan&.plan_type || @provider.all_descendants.joins(:plan).pluck(:plan_type)
                                                          .uniq.first || "rocketcyber"
  end

  def sla
    Upload.support_files.includes(:sourceable).where("filename LIKE ?", "%RocketCyberSLA%")
          .reorder("created_at DESC").first
  end

  def build_provider
    @provider = Provider.new(provider_params)

    # Admins can only create sub-providers with this form.
    @provider.path = current_provider.path if nest? || current_user.admin_role
    @provider.agent_release_group = current_provider.agent_release_group if nest? || current_user.admin_role

    @provider.users << current_user unless current_user.admin_role # Defaults to owner
  end

  def find_provider
    @provider = Provider.find(params[:id].to_i)
  end

  def provider_params
    available_params = params.require(:provider).permit(
      :name, :logo_id, :skip_nesting, :contact_name, :street_1, :street_2,
      :city, :state, :zip_code, :settings_inheritance, :alien_vault_api_key,
      :virus_total_api_key, :emails, :enable_customer_notifications
    ).to_h

    available_params.merge!(
      params.require(:provider).permit(
        setting_attributes: [
          :can_customize_logo, :channel, :uninstall, :url, :license_key, :verbosity, :offline, :super,
          :polling, :parallel_sub_task_count, :file_hash_refresh_interval, :app_result_cache_age,
          :max_cpu_usage, :max_memory_usage, :max_sustained_memory_usage, :auto_remediate,
          :user_session_timeout, :device_expiration, two_factors: %i[accounts sub_accounts]
        ]
      )
    )

    available_params.deep_merge!(device_inactivity_thresholds_params) if params[:device_inactivity_thresholds]

    available_params.deep_merge!(omnipotent_params) if @provider && policy(@provider).admin?
    available_params
  end

  def device_inactivity_thresholds_params
    inactivity_params = params[:device_inactivity_thresholds].permit!.to_h
    inactivity_params.reject { |_k, v| v.blank? }
    params.require(:provider).permit(:device_inactivity_thresholds).merge(
      setting_attributes: { device_inactivity_thresholds: inactivity_params }
    )
  end

  def omnipotent_params
    params.require(:provider).permit(
      :paid_thru, :unset_plan, :disable_sub_subscriptions, :agent_release_group
    ).to_h.merge({
                   setting_attributes: {
                     admin_config: admin_config_params
                   }.reject { |_k, v| v.blank? }
                 }).reject { |_k, v| v.blank? }
  end

  def admin_config_params
    if params[:admin_config]
      params[:admin_config].permit!.to_h.merge(new_admin_config)
    else
      new_admin_config
    end
  end

  def new_admin_config
    return {} if params[:admin_config_new_key].blank? || params[:admin_config_new_value].blank?

    { params[:admin_config_new_key] => params[:admin_config_new_value] }
  end

  def nest?
    current_provider &&
      policy(current_provider).create_sub_providers?
  end

  # Agents have stopped checking for new hunts when actionable_past_due?
  # Send message to re-activate them
  def broadcast_check_for_hunts!
    @provider.self_and_all_descendant_customers.each do |customer|
      ServiceRunnerJob.perform_later(
        "DeviceBroadcasts::Customer",
        customer,
        { type: "hunts", payload: {} }.to_json
      )
    end
  end

  # Agents have stopped checking for new apps when actionable_past_due?
  # Send message to re-activate them
  def broadcast_check_for_apps!
    @provider.self_and_all_descendant_customers.each do |customer|
      ServiceRunnerJob.perform_later(
        "DeviceBroadcasts::Customer",
        customer,
        { type: "apps", payload: {} }.to_json
      )
    end
  end

  def skip_credit_card_required?
    true
  end

  def provider_created_path
    @provider.completed? ? provider_path(@provider) : Onboarding::Router.new(@provider).call
  end

  def extend_trial_days_params
    params.require(:provider).permit(:extend_days)
  end
end
