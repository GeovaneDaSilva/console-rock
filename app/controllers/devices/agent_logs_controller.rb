module Devices
  # Execute the upload agent log command, show agent logs
  class AgentLogsController < AuthenticatedController
    include Pagy::Backend

    def index
      authorize device, :show?

      @pagination, @agent_logs = pagy @device.agent_logs.includes(:upload)
    end

    def create
      authorize device, :show?

      device_log!
      device_broadcast!

      flash[:notice] = "Requested device upload the most recent agent log"

      respond_to do |format|
        format.html do
          redirect_to device_path(device)
        end

        format.js
      end
    end

    def destroy
      authorize device, :destroy?

      log = Devices::AgentLog.find(params[:id])

      if log.destroy
        flash[:notice] = "Log deleted"
      else
        flash[:error] = "Unable to delete log"
      end

      redirect_to device_path(device, anchor: "logs")
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
        device.logs.create(payload: "Requested device upload the most recent agent log")
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
        type:    "upload_agent_log",
        payload: {}
      }
    end
  end
end
