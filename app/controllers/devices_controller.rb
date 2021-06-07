# Customer's devices
class DevicesController < AuthenticatedController
  include Pagy::Backend
  include Sortable

  sortable :devices, *%w[
    hostname ipv4_address::inet accounts.name version suspicious_count malicious_count
  ]
  sortable :billable_instances, *%w[details->>'device_id'
                                    details->>'type'
                                    details->>'ip'
                                    details->>'mac']

  before_action :device, only: %i[show destroy]
  helper_method :device, :apps, :discreet_apps, :manual_hunts, :continuous_hunts,
                :feed_hunts, :agent_logs

  def index
    authorize(current_account, :view_devices?)

    unless params[:firewalls_only]
      @devices_pagination, @filtered_devices = pagy filtered_devices, page_param: :devices_page
    end

    @firewalls = current_account.all_descendant_billable_instances.firewall
                                .joins("JOIN accounts ON accounts.path = billable_instances.account_path")
                                .order(billable_instances_sort_by_clause.presence || Arel.sql("active DESC"))
    apply_firewall_filter if params[:firewall_filter].present?
    @firewalls_pagination, @firewalls = pagy @firewalls, page_param: :firewalls_page
  end

  def custom_update
    authorize(current_account, :can_comment_firewalls_and_devices?)
    klass = params["type"] == "firewall" ? BillableInstance : Device
    device = klass.find(params["device_id"])
    params["details"].each do |k, v|
      device.details = {} if device.details.nil?
      device.details[k] = v
    end
    device.save
    render json: device
  end

  def show
    authorize device

    @agent_logs_pagination, @agent_logs = paginate_agent_logs
  end

  def inventory
    authorize device, :view_devices?
    @inventory = device.macos? ? device.macos_inventory : {}
    render layout: false
  end

  def create
    authorize(current_account, :destroy?)

    case params[:custom_action].downcase
    when "delete"
      total = destroy_by_batch(params[:devices])
      flash[:notice] = "#{total} - Devices flagged for deletion."
    end

    redirect_to devices_path
  end

  def destroy
    authorize @device, :destroy?

    respond_to do |format|
      format.js do
        @job_id = PolledTaskRunner.new.call(
          "Devices::Destroy", @device
        ).key.split("/").last

        @result_path = devices_path
        render "customers/destroy"
      end
    end
  end

  private

  def destroy_by_batch(device_ids)
    return 0 if device_ids.blank?

    devices = current_account.all_descendant_devices.where(id: device_ids)

    # mark for deletion
    total_affected_devices = devices.update_all(marked_for_deletion: true)

    # enqueue to delete
    devices.each do |device|
      ServiceRunnerJob.set(queue: :utility).perform_later("Devices::Destroy", device)
    end

    total_affected_devices
  end

  def device
    id = params[:id] || params[:device_id]
    @device ||= devices.find(id.downcase)
  end

  def devices
    @devices ||= (current_account&.all_descendant_devices || Device.all)
                 .not_deleted
                 .joins(:customer)
  end

  def filtered_devices
    items = devices.order(devices_sort_by_clause.presence || Arel.sql("connectivity DESC"))
    items = items.online if params[:online_only]
    items = items.offline if params[:offline_only]
    items = items.inactive if params[:inactive_only]
    items = items.isolated if params[:isolated_only]
    items = items.fuzzy_search(params[:filter]) if params[:filter].present?
    items = items.where("last_connected_at >= ?", params[:start_date]) if params[:start_date].present?
    items = items.where("last_connected_at <= ?", params[:end_date]) if params[:end_date].present?
    items
  end

  def apps
    @apps ||= App.enabled.ga.order("title ASC").includes(:display_image_icon).load
  end

  def discreet_apps
    App.discreet
  end

  def manual_hunts
    @manual_hunts ||= Hunt.manual.not_continuous.where(group_id: device.group_ids)
  end

  def feed_hunts
    @feed_hunts ||= device.latest_revision_completed_hunts
                          .feed
                          .enabled.malicious.not_continuous
                          .joins(:hunt_results)
                          .where(hunt_results: { archived: false, result: :positive })
                          .distinct
  end

  def continuous_hunts
    @continuous_hunts ||= Hunt.manual.continuous.where(group_id: device.group_ids)
  end

  def agent_logs
    @agent_logs ||= device.agent_logs.includes(:upload)
  end

  def paginate_agent_logs
    pagy agent_logs, page_param: :agent_logs_page
  end

  def apply_firewall_filter
    vals = []
    where_str = %w[type mac ip device_id].collect do |t|
      vals << params[:firewall_filter]
      " details->>'#{t}' = ? "
    end.join("OR")
    @firewalls = @firewalls.where(where_str, *vals)
  end
end
