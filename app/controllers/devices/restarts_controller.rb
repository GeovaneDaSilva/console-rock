module Devices
  # Execute the restart agent device command
  class RestartsController < AuthenticatedController
    def create
      authorize device.customer, :can_manage_apps?

      device_log!
      device_broadcast!

      flash[:notice] = "Requested agent restart"

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
        device.logs.create(payload: "Requested agent restart")
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
        type:    "agent_restart",
        payload: {}
      }
    end
  end
end
