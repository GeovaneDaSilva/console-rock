module Devices
  # Send the given app message to the device
  class AppActionsController < AuthenticatedController
    include AppActionable

    def create
      authorize device, :app_action?

      device_log!
      device_broadcast!

      flash[:notice] = "Requested device #{action[:description].downcase}"

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
        device.logs.create(payload: "Requested device #{action[:description].downcase}")
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
  end
end
