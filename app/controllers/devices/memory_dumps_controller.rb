module Devices
  # Execute the memory_dump device command
  class MemoryDumpsController < AuthenticatedController
    def create
      authorize device, :memory_dump?

      device_log!
      device_broadcast!

      flash[:notice] = "Requested device memory dump"

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
        device.logs.create(payload: "Requested device create memory dump")
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
        type: "memory_dump"
      }
    end
  end
end
