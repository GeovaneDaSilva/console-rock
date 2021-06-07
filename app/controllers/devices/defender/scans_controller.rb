module Devices
  module Defender
    # Controller for device defender scans
    class ScansController < BaseController
      def create
        device_log!
        device_broadcast!

        flash[:notice] = "Requested agent initiate a Windows Defender #{scan_type.humanize} Scan"

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
          device.logs.create(
            payload: "Requested agent initiate a Windows Defender #{scan_type.humanize} Scan"
          )
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
          type:    "defender_scan",
          payload: {
            scan_type: scan_type
          }
        }
      end

      def scan_type
        case params[:scan_type]
        when "quick"
          "quick"
        when "full"
          "full"
        end
      end
    end
  end
end
