module Administration
  # :nodoc
  class AppsController < BaseController
    include Pagy::Backend

    helper_method :apps, :app

    def index
      authorize(:administration, :view_apps?)
      @pagination, @apps = pagy apps
    end

    def show
      authorize(:administration, :view_apps?)
    end

    def new
      authorize(:administration, :manage_apps?)

      @app = App.new
    end

    def edit
      authorize(:administration, :manage_apps?)
    end

    def create
      authorize(:administration, :manage_apps?)

      @app = App.new(app_params)

      if @app.save
        flash[:notice] = "Created App"
        redirect_to administration_app_path(@app)
      else
        flash.now[:error] = "Unable to create App"
        render :new
      end
    end

    def update
      authorize(:administration, :manage_apps?)

      if app.update(app_params)
        flash[:notice] = "Updated App"
        redirect_to administration_app_path(app)
      else
        flash.now[:error] = "Unable to update App"
        render :edit
      end
    end

    def destroy
      authorize(:administration, :manage_apps?)
      if app.destroy
        flash[:notice] = "App deleted"
        redirect_to administration_apps_path
      else
        flash[:error] = "Unable to delete App"
        redirect_to administration_app_path(app)
      end
    end

    private

    def app_params
      params.require(:app).permit(
        :title, :price, :description, :display_image_id, :on_by_default,
        :display_image_icon_id, :upload_id, :indicator, :report_template,
        :configuration_type, :author, :disabled, :type, :discreet,
        platforms: [], configuration_scopes: [], additional_types: []
      )
    end

    def apps
      App.order(:title)
    end

    def app
      @app ||= App.find(params[:id])
    end
  end
end
