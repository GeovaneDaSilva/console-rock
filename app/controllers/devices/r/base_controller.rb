module Devices
  module R
    # Base controller for individual device reports
    class BaseController < AuthenticatedController
      layout "reports"

      private

      def device
        @device ||= Device.find(params[:device_id])
      end
    end
  end
end
