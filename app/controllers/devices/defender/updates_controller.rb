module Devices
  module Defender
    # Base controller for device defender actions
    class UpdatesController < BaseController
      def create
        device_log!
        device_broadcast!

        flash[:notice] = "Requested agent update Windows Defender Signatures"

        respond_to do |format|
          format.html do
            redirect_to device_path(device)
          end

          format.js
        end
      end

      private

      def device_log!
        ServiceRunnerJob.set(queue: "ui").perform_later(
          "Broadcasts::Devices::Logs",
          device,
          device.logs.create(payload: "Requested agent update Windows Defender Signatures")
        )
      end

      def device_broadcast!
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Device",
          device.id,
          broadcast_message.to_json
        )
      end

      def broadcast_message
        {
          type:    "defender_signature_update",
          payload: {}
        }
      end
    end
  end
end
