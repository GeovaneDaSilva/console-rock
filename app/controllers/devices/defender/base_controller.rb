module Devices
  module Defender
    # Base controller for device defender actions
    class BaseController < AuthenticatedController
      before_action :authorize_device_actions!

      private

      def authorize_device_actions!
        authorize device, :defender_action?
      end

      def device
        Device.find(params[:device_id])
      end
    end
  end
end
