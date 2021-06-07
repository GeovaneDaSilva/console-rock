module Devices
  # Device app based actions
  class AppsController < AuthenticatedController
    # Destroy all the app results for the given app
    def destroy
      authorize device, :destroy?

      ApplicationRecord.transaction do
        app_results.find_each(&:destroy)
      end

      redirect_back fallback_location: device_path(params[:device_id])
    end

    private

    def app_results
      @app_results ||= device.app_results.where(app_id: params[:id])
    end

    def device
      @device ||= Device.find(params[:device_id])
    end
  end
end
