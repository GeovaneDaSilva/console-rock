# current_account's groups
class GroupsController < AuthenticatedController
  include Pagy::Backend

  before_action :find_group, only: %I[show edit update destroy]

  def index
    authorize(current_account, :view_groups?)
    @groups = Group.where(account: current_account)
                   .includes(:account)
                   .order("created_at DESC")
    @pagination, @groups = pagy @groups
  end

  def show
    authorize @group

    respond_to do |format|
      format.html { load_group_devices }
      format.js do
        @job_id = PolledTaskRunner.new.call(
          report_type,
          @group,
          download_opts.to_json
        ).key.split("/").last
        render partial: "shared/download_report"
      end
    end
  end

  def new
    authorize(current_account, :edit?)
    @group = current_account.groups.new(group_params)

    load_group_devices
    load_group_filters
  end

  def create
    authorize(current_account, :edit?)

    @group = current_account.groups.new(group_params)

    if @group.save
      flash[:notice] = "Group created"
      @group.broadcast_changes!
      redirect_to group_path(@group)
    else
      flash.now[:error] = "Unable to create group"
      load_group_devices
      load_group_filters

      render "new"
    end
  end

  def edit
    authorize @group
    @group.assign_attributes(@group.attributes.merge(group_params))

    load_group_devices
    load_group_filters
  end

  def update
    authorize @group

    if @group.update(group_params)
      flash[:notice] = "Group updated"
      @group.broadcast_changes!

      redirect_to group_path(@group)
    else
      flash.now[:error] = "Unable to update group"
      load_group_devices
      load_group_filters

      render "edit"
    end
  end

  def destroy
    authorize @group

    if policy(@group).destroy? && @group.destroy
      flash[:notice] = "Group destroyed"

      redirect_to groups_path
    else
      flash[:error] = "Unable to destroy group"
      redirect_to group_path(group)
    end
  end

  private

  def find_group
    @group ||= Group.where(account: current_account.self_and_all_descendants)
                    .find(params[:id])
  end

  def load_group_devices
    @devices = @group.device_query
                     .recently_connected
    @pagination, @devices = pagy @devices, items: 20
  end

  def load_group_filters
    device_scope = current_account.all_descendant_devices

    @networks = device_scope.select(:network).distinct.collect { |d| [d.network, d.network] }

    @operating_systems = device_scope.select(:family, :version, :edition).distinct.collect do |d|
      joined = [d.family, d.version, d.edition].join(" ")
      [joined, joined].reject(&:blank?)
    end.reject(&:blank?)

    @public_ips = EgressIp.where(customer: current_account.self_and_all_descendants)
                          .select(:ip).distinct.collect { |eip| [eip.ip, eip.ip] }
  end

  def download_opts
    {
      attrs:         %I[id hostname ipv4_address mac_address network os],
      header_values: %I[fingerprint hostname ip mac network os],
      filename:      "#{current_account.name.parameterize}-all-devices"
    }
  end

  def group_params
    params.require(:group).permit(
      :name, :query, :network, :os, :public_ip, :family_version_and_edition,
      query_fields: []
    )
  rescue ActionController::ParameterMissing
    { query_fields: Group.values_for_query_fields }
  end

  def report_type
    case params[:type]
    when "csv"
      "Reports::GroupDevices::CsvReporter"
      # when "xlsx"
      #   "Reports::GroupDevices::XlsxReporter"
    end
  end
end
