module Devices
  # Execute the device inventory commands
  class InventoriesController < AuthenticatedController
    def create
      authorize device, :show?

      device_log!
      device_broadcast!

      flash[:notice] = "Requested device update inventory"

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
        device.logs.create(payload: "Requested device update inventory")
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
      { type: "inventory" }
    end
  end
end
