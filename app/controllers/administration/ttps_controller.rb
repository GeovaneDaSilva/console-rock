module Administration
  # :nodoc
  class TTPsController < BaseController
    include Pagy::Backend

    before_action :ttp, except: %i[index new create]

    def index
      ttps = TTP.order(:id)
      ttps = ttps.basic_search(params[:search]) if params[:search].present?

      @pagination, @ttps = pagy ttps
    end

    def show; end

    def new
      @ttp = TTP.new
    end

    def edit; end

    def create
      @ttp = TTP.new(ttp_params)

      if @ttp.save
        flash[:notice] = "Created TTP"
        redirect_to administration_ttp_path(ttp)
      else
        flash.now[:error] = "Unable to create TTP"
        render :new
      end
    end

    def update
      if ttp.update(ttp_params)
        flash[:notice] = "Updated ttp"
        redirect_to administration_ttp_path(ttp)
      else
        flash.now[:error] = "Unable to update TTP"
        render :edit
      end
    end

    def destroy
      if ttp.destroy
        flash[:notice] = "TTP deleted"
        redirect_to administration_ttps_path
      else
        flash[:error] = "Unable to delete TTP"
        redirect_to administration_ttp_path(ttp)
      end
    end

    private

    def ttp
      @ttp ||= TTP.find(params[:id])
    end

    def ttp_params
      params.require(:ttp)
            .permit(:id, :tactic, :description, :technique, :description, :url, :remediation)
    end
  end
end
