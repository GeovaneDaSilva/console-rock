module Devices
  module Hunts
    # Act upon a specifc hunt result
    class ResultsController < AuthenticatedController
      # destroy the given hunt result
      def destroy
        authorize device, :destroy?

        hunt_result.destroy

        redirect_back fallback_location: device_path(params[:device_id])
      end

      private

      def hunt_result
        @hunt_result ||= device.hunt_results.find(params[:id])
      end

      def device
        @device ||= Device.find(params[:device_id])
      end
    end
  end
end
