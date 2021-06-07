# :nodoc
class HuntsController < AuthenticatedController
  include Pagy::Backend

  before_action :groups, only: %i[new edit]
  before_action :paginate_devices, only: %i[show edit]

  helper_method :available_test_types

  def index
    authorize current_account, :view_threat_hunts?
    @pagination, @hunts = pagy hunts.manual
  end

  def show
    authorize current_account, :view_threat_hunts?

    if current_account.customer?
      @agent_url = api_customer_support_url(
        current_account.license_key, "#{ENV['AGENT_FILE_NAME']}.exe"
      )
    end
  end

  def new
    authorize current_account, :can_modify_threat_hunts?

    @hunt = Hunt.new
    @hunt.build_tests(nil, current_user.admin?)
  end

  def create
    @hunt = Hunt.new(revision: 0, group: group)
    authorize hunt, :edit?

    @hunt.assign_attributes(hunt_params)
    if @hunt.tests.size.positive? && @hunt.save
      flash[:notice] = "Hunt successfully created"
      queue_hunts_broadcast!

      redirect_to hunt_path(@hunt)
    else
      groups
      flash.now[:error] = "Unable to create hunt"
      render "new"
    end
  end

  def edit
    authorize hunt, :edit?
  end

  def update
    authorize hunt, :edit?
    hunt.assign_attributes(hunt_params.merge(group: group))

    if hunt.revision_tests.size.positive? && hunt.save
      flash[:notice] = "Successfully updated hunt"
      queue_hunts_broadcast!

      redirect_to hunt_path(@hunt)
    else
      devices
      flash.now[:error] = "Unable to update hunt"
      render "edit"
    end
  end

  def destroy
    authorize hunt, :edit?

    if Hunts::Destroyer.new(hunt).call
      flash[:notice] = "Hunt destroyed"
      redirect_to hunts_path
    else
      flash[:error] = "Unable to destroy hunt"
      redirect_to hunt_path(hunt)
    end
  end

  private

  def hunt
    @hunt ||= hunts.find(params[:id])
  end

  def hunts
    @hunts ||= Hunt.joins(:group).includes(:group).where(
      groups: { account: current_account.self_and_all_ancestors }
    )
  end

  def group
    @group ||= groups.find(params.dig("hunt", "group_id"))
  end

  def groups
    @groups ||= Group.where(account: current_account)
  end

  def new_hunt_revision
    @new_hunt_revision ||= hunt.revision + 1
  end

  def hunt_params
    params.require(:hunt).permit(
      :name, :matching, :indicator, :continuous,
      tests_attributes:
                        [
                          :type, :_destroy, :lua_script_upload_id, :lua_script_description,
                          conditions_attributes: %i[type operator condition order]
                        ]
    ).merge(revision: new_hunt_revision)
  end

  def devices
    devices = hunt.group.device_query
    if params.key? :result
      devices = devices.joins(:hunt_results).where(
        { hunt_results: { result: params[:result], hunt_revision_id: hunt.revision_id } }
      )
    end
    @devices ||= devices.recently_connected
  end

  def paginate_devices
    @pagination, @devices = pagy devices, items: 20
  end

  def available_test_types
    if current_user.admin?
      Hunts::TEST_TYPES
    else
      Hunts::TEST_TYPES - Hunts::ADMIN_TESTS
    end
  end

  def queue_hunts_broadcast!
    ServiceRunnerJob.set(queue: "ui").perform_later("Broadcasts::Hunts::Changed", hunt)
  end
end
