module Devices
  # Device isolation actions
  class IsolationController < AuthenticatedController
    def update
      authorize current_account, :manage_device_isolation?

      if action
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Device", params[:device_id],
          { type: action, payload: {} }.to_json
        )
        flash[:notice] = "#{action.humanize} command sent"
      else
        flash.now[:error] = "Error sending command"
      end

      redirect_back fallback_location: device_path(params[:device_id])
    end

    private

    def action
      return @action unless @action.nil?

      @action = if params[:isolate]
                  "isolate_device"
                elsif params[:restore]
                  "restore_device"
                else
                  false
                end
    end
  end
end
