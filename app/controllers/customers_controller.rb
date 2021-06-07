# :nodoc
class CustomersController < AuthenticatedController
  include Pagy::Backend
  include Sortable

  sortable :customers, *%w[name path]
  before_action :find_customer, only: %i[show edit update destroy]

  def index
    skip_authorization

    @customers = customer_scope.order(
      customers_sort_by_clause.presence || Arel.sql("name")
    )

    @customers = @customers.fuzzy_search(params[:filter]) if params[:filter].present?

    @pagination, @customers = pagy @customers
  end

  def show
    authorize(@customer)

    @email_subscription = Subscriptions::Email.find_or_initialize_by(account: @customer)

    if policy(@customer).can_modify_plan?
      @plans = policy_scope(Plan).includes(:apps).where(plan_type: @customer.billing_account.plan.plan_type)
                                 .order("price_per_frequency_cents ASC, price_per_device_overage_cents ASC")
      @charges = @customer.charges.includes(:plan).order("created_at desc")
    end
  end

  def new
    authorize(current_provider, :create_customers?)
    @customer = Customer.new(path: current_provider.path)
  end

  def create
    authorize(current_provider, :create_customers?)

    @customer = Customer.new(customer_params)
    @customer.path = find_parent.path

    if @customer.save
      flash[:notice] = "Successfully created new customer"
      session[:account_id] = @customer.id
      AdministrationMailer.new_account(@customer).deliver_later

      redirect_to customer_agents_url(customer_id: @customer.id)
    else
      flash.now[:error] = "Unable to create new customer"
    end
  end

  def update
    authorize @customer

    if @customer.update(customer_params)
      @customer.setting.broadcast_changes!
      @customer.users.update_all(session_timeout: @customer.setting.user_session_timeout)
      flash[:notice] = "Customer updated"
    else
      flash.now[:error] = "Unable to update customer"
    end
    redirect_to customer_path(@customer)
  end

  def destroy
    authorize @customer, :destroy?

    respond_to do |format|
      format.js do
        @job_id = PolledTaskRunner.new.call(
          "Accounts::Destroyer", @customer
        ).key.split("/").last

        @result_path = root_path

        render "customers/destroy"
      end
    end
  end

  private

  def customer_params
    available_params = params.require(:customer).permit(
      :name, :logo_id, :skip_nesting, :contact_name, :street_1, :street_2,
      :city, :state, :zip_code, :settings_inheritance, :alien_vault_api_key,
      :virus_total_api_key, :emails, :enable_customer_notifications
    ).to_h

    available_params.merge!(
      params.require(:customer).permit(
        setting_attributes: %i[
          can_customize_logo channel uninstall url license_key verbosity offline super polling
          parallel_sub_task_count file_hash_refresh_interval app_result_cache_age max_cpu_usage
          max_memory_usage max_sustained_memory_usage auto_remediate user_session_timeout device_expiration
        ]
      )
    )

    available_params = customer_params_deep_merge(available_params)

    unless available_params[:name].nil?
      available_params[:name] = available_params[:name].encode("UTF-8", invalid: :replace,
        undef: :replace, replace: "")
    end

    available_params
  end

  def customer_params_deep_merge(available_params)
    available_params.deep_merge!(device_inactivity_thresholds_params) if params[:device_inactivity_thresholds]
    available_params.deep_merge!(omnipotent_params) if @customer && policy(@customer).admin?
    available_params
  end

  def device_inactivity_thresholds_params
    inactivity_params = params[:device_inactivity_thresholds].permit!.to_h
    inactivity_params.reject! { |_k, v| v.blank? }
    params.require(:customer).permit(:device_inactivity_thresholds).merge(
      setting_attributes: { device_inactivity_thresholds: inactivity_params }
    )
  end

  def omnipotent_params
    params.require(:customer).permit(
      :paid_thru, :unset_plan, :disable_sub_subscriptions, :agent_release_group
    ).to_h.merge(setting_attributes: { admin_config: admin_config_params })
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

  def find_parent
    current_provider.children.providers.where(id: params.dig("customer", "id")).first ||
      current_provider
  end

  def find_customer
    @customer ||= Customer.find(params[:id])
  end

  def customer_scope
    if current_account.provider?
      current_account.self_and_all_descendant_customers
    elsif policy(current_account.parent).show?
      current_account.parent.self_and_all_descendant_customers
    else
      Customer.where(id: current_account)
    end
  end

  def load_group_data
    search_options = { per_page: 1, load: false, execute: false }
    @groups = @customer.groups.order("created_at DESC").limit(10)
    @groups.collect { |group| group.device_query(search_options) }.page(0).per(1)
  end
end
