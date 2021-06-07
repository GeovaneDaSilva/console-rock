module Devices
  # Execute the update device command
  class UpdatesController < AuthenticatedController
    def create
      authorize device, :defender_action?

      device_log!
      device_broadcast!

      flash[:notice] = "Requested device check for updates"

      respond_to do |format|
        format.html do
          redirect_to device_path(device)
        end

        format.js
      end
    end

    private

    def device
      @device ||= current_account.all_descendant_devices
                                 .find(params[:device_id].downcase)
    end

    def device_log!
      ServiceRunnerJob.set(queue: "ui").perform_later(
        "Broadcasts::Devices::Logs",
        device,
        device.logs.create(payload: "Requested device check for updates")
      )
    end

    def device_broadcast!
      ServiceRunnerJob.perform_later(
        "DeviceBroadcasts::Device",
        device.id,
        broadcast_message.to_json,
        true
      )
    end

    def broadcast_message
      {
        type:    "check_for_updates",
        payload: {}
      }
    end
  end
end
