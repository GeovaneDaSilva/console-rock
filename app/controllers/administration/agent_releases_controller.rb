module Administration
  # Admin views for agent releases
  class AgentReleasesController < Administration::BaseController
    include Pagy::Backend

    def index
      authorize(:administration, :manage_agent_releases?)

      @agent_releases = AgentRelease.includes(:creator)
                                    .order("agent_releases.created_at DESC")
      @pagination, @agent_releases = pagy @agent_releases
    end

    def new
      authorize(:administration, :manage_agent_releases?)

      @agent_release = AgentRelease.new
    end

    def create
      authorize(:administration, :manage_agent_releases?)

      @agent_release = AgentRelease.new(agent_release_params)
      @agent_release.creator = current_user
      @agent_release.upload_ids = all_current_uploads

      if @agent_release.save
        flash[:notice] = "Created Agent Release #{@agent_release.id}"
        ServiceRunnerJob.set(wait: 1.second).perform_later("AgentReleases::Releaser")
        redirect_to administration_agent_release_path(@agent_release, anchor: :customers)
      else
        flash.now[:error] = "Unable to create release"
        render :new
      end
    end

    def show
      authorize(:administration, :manage_agent_releases?)

      @agent_release = AgentRelease.find(params[:id])
      @customers = @agent_release.all_targeted_customers
                                 .where("accounts.name ILIKE ?", "%#{params[:search]}%")
                                 .order("agent_release_id DESC")
      @customers_pagination, @customers = pagy @customers

      @not_targeted_customers = @agent_release.all_not_targeted_customers
                                              .order("agent_release_id DESC")
      @not_targeted_pagination, @not_targeted_customers = pagy(
        @not_targeted_customers, page_param: :not_targeted
      )
    end

    def update
      authorize(:administration, :manage_agent_releases?)

      agent_release = AgentRelease.find(params[:id])
      customer = Customer.find(params[:customer_id])

      customer.update(agent_release_id: agent_release.id)
      ServiceRunnerJob.perform_later("AgentReleases::Releaser")

      flash[:notice] = "Forced release of #{customer.name}"

      redirect_to administration_agent_release_path(agent_release)
    end

    def destroy
      authorize(:administration, :manage_agent_releases?)

      AgentRelease.find(params[:id]).destroy

      ServiceRunnerJob.perform_later("AgentReleases::Releaser")
      flash[:notice] = "Removed release #{params[:id]}"

      redirect_to administration_agent_releases_path
    end

    private

    def agent_release_params
      params.require(:agent_release).permit(
        :description, :period, agent_release_groups: []
      )
    end

    def all_current_uploads
      Upload.support_files.to_a.group_by(&:filename).collect do |_, uploads|
        uploads.max_by(&:created_at).id
      end
    end
  end
end
