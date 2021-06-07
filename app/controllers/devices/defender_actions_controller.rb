module Devices
  # Execute the given defender action command
  class DefenderActionsController < AuthenticatedController
    def update
      authorize device, :defender_action?

      if defender_action && update_app_result!
        device_log!
        device_broadcast!

        flash[:notice] = "Requested Defender #{defender_action.humanize} #{app_result.details.threat_name}"
      else
        flash[:error] = "Unable to perform defender action"
      end

      respond_to do |format|
        format.html do
          redirect_to device_path(device, anchor: "defender")
        end
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
        device.logs.create(
          payload: "Requested Defender #{defender_action.humanize} #{app_result.details.threat_name}"
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
        type:    "defender_action",
        payload: {
          detection_id: app_result.details.detection_id,
          threat_name:  app_result.details.threat_name,
          files:        app_result.details.files.to_a,
          action:       defender_action,
          success_url:  api_device_result_resolve_path(device, app_result, format: :json),
          error_url:    api_device_result_error_path(device, app_result, format: :json)
        }
      }
    end

    def app_result
      @app_result ||= device.app_results.find(params[:id])
    end

    def update_app_result!
      app_result.update(
        action_state:  :requested,
        action_result: {
          request: { action: defender_action, requestor_id: current_user.id, date: DateTime.now }
        }
      )
    end

    def available_actions
      @available_actions ||= app_result.details.suggested_actions.collect(&:parameterize)
    end

    def defender_action
      params[:defender_action] if available_actions.include?(params[:defender_action])
    end
  end
end
