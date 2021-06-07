# :nodoc
class DefendersController < AuthenticatedController
  include Pagy::Backend
  include Sortable

  sortable :at_risk_devices, *%w[hostname ipv4_address::inet accounts.name version]
  sortable :unhealthy_devices, *%w[hostname ipv4_address::inet accounts.name version defender_health_status]
  sortable :unknown_health_devices,
           *%w[hostname ipv4_address::inet accounts.name version defender_health_status]

  helper_method :devices_with_app_results, :app, :unhealthy_devices, :unknown_health_devices

  def show
    authorize current_account, :defender_enabled_in_tree?

    @at_risk_devices_pagination, @devices_with_app_results = pagy(
      devices_with_app_results, page_param: :at_risk_devices
    )
    @unknown_health_devices_pagination, @unknown_health_devices = pagy(
      unknown_health_devices, page_param: :unknown_health_devices
    )
    @unhealthy_devices_pagination, @unhealthy_devices = pagy(
      unhealthy_devices, page_param: :unhealthy_devices
    )
  end

  private

  def devices_with_app_results
    if params[:at_risk_filter].present?
      all_devices_with_app_results.where("hostname ILIKE ?", "%#{params[:at_risk_filter]}%")
    else
      all_devices_with_app_results
    end
  end

  def unknown_health_devices
    if params[:unknown_health_filter].present?
      all_unknown_health_devices.where("hostname ILIKE ?", "%#{params[:unknown_health_filter]}%")
    else
      all_unknown_health_devices
    end
  end

  def unhealthy_devices
    if params[:unhealthy_filter].present?
      all_unhealthy_devices.where("hostname ILIKE ?", "%#{params[:unhealthy_filter]}%")
    else
      all_unhealthy_devices
    end
  end

  def all_devices_with_app_results
    current_account.all_descendant_devices.includes(app_results: [:app])
                   .joins(:customer)
                   .order(at_risk_devices_sort_by_clause.presence || Arel.sql("connectivity DESC"))
                   .where(
                     apps: { configuration_type: App.configuration_types[:defender] }
                   )
  end

  def all_unhealthy_devices
    current_account.all_descendant_devices.defender_health_status_unhealthy
                   .joins(:customer)
                   .order(unhealthy_devices_sort_by_clause.presence || Arel.sql("connectivity DESC"))
  end

  def all_unknown_health_devices
    current_account.all_descendant_devices.defender_health_status_unknown
                   .joins(:customer)
                   .order(unknown_health_devices_sort_by_clause.presence || Arel.sql("connectivity DESC"))
  end

  def app
    @app ||= App.where(configuration_type: :defender).first
  end
end
