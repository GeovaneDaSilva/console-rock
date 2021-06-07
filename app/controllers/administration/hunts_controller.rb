module Administration
  # :nodoc
  class HuntsController < BaseController
    include Pagy::Backend

    after_action :queue_feed_updates!, only: %i[create update destroy]

    def index
      @pagination, @hunts = pagy hunts
    end

    def show
      @hunt = hunt
    end

    def new
      @hunt = Hunt.new
      @hunt.build_tests(nil, current_user.admin?)
    end

    def create
      @hunt = Hunt.new(revision: 0)
      @hunt.assign_attributes(hunt_params.merge(group_id: 0))
      if @hunt.save
        flash[:notice] = "Hunt successfully created"

        redirect_to administration_hunt_path(@hunt)
      else
        flash.now[:error] = "Unable to create hunt"
        render "new"
      end
    end

    def edit
      @hunt = hunt
    end

    def update
      if hunt.update(hunt_params)
        flash[:notice] = "Successfully updated hunt"

        redirect_to administration_hunt_path(@hunt)
      else
        flash.now[:error] = "Unable to update hunt"
        render "edit"
      end
    end

    def destroy
      if hunt.update(disabled: true)
        flash[:notice] = "Hunt destroyed"
        redirect_to administration_hunts_path
      else
        flash[:error] = "Unable to destroy hunt"
        redirect_to administration_hunt_path(hunt)
      end
    end

    private

    def hunt
      @hunt ||= hunts.find(params[:id])
    end

    def hunts
      @hunts ||= Hunt.system_hunt_feeds.enabled
    end

    def new_hunt_revision
      @new_hunt_revision ||= hunt.revision + 1
    end

    def hunt_params
      params.require(:hunt).permit(
        :name, :description, :matching, :indicator, :continuous,
        :on_by_default, :category_id,
        tests_attributes:
                          [
                            :type, :_destroy, :lua_script_upload_id, :lua_script_description,
                            conditions_attributes: %i[type operator condition order]
                          ]
      ).merge(revision: new_hunt_revision)
    end

    def queue_feed_updates!
      ServiceRunnerJob.perform_later("Hunts::Feeds::Updater", "system_hunts")
    end
  end
end
