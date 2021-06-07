module Devices
  module Apps
    # Act upon a specific app result
    class ResultsController < AuthenticatedController
      # destroy the given app result
      def destroy
        authorize device, :destroy?

        app_result.destroy

        redirect_back fallback_location: device_path(params[:device_id])
      end

      private

      def app_result
        @app_result ||= device.app_results.find(params[:id])
      end

      def device
        @device ||= Device.find(params[:device_id])
      end
    end
  end
end
