module Hunts
  # Execute the given hunt now
  class ManualRunsController < AuthenticatedController
    # Run against all devices
    def create
      authorize hunt, :run_manually?

      group_broadcast!

      flash[:notice] = "Requested hunt #{hunt.name} run on all applicable devices"

      respond_to do |format|
        format.html do
          redirect_back fallback_location: proc { hunt_path(hunt) }
        end

        format.js
      end
    end

    # Run against a single device
    def update
      authorize hunt, :run_manually?

      device_log!
      device_broadcast!

      flash[:notice] = "Requested hunt #{hunt.name} run on #{device.hostname}"

      respond_to do |format|
        format.html do
          redirect_back fallback_location: proc { hunt_path(hunt) }
        end

        format.js
      end
    end

    private

    def hunt
      @hunt ||= Hunt.joins(:group).where(groups: { account: account_scope }).find(params[:hunt_id])
    end

    def device
      @device ||= current_account.all_descendant_devices
                                 .find(params[:id].downcase)
    end

    def account_scope
      current_account.self_and_all_ancestors
    end

    def device_log!
      ServiceRunnerJob.set(queue: "ui").perform_later(
        "Broadcasts::Devices::Logs",
        device,
        device.logs.create(payload: "Requested device run Hunt #{hunt.name}")
      )
    end

    def group_broadcast!
      ServiceRunnerJob.perform_later(
        "DeviceBroadcasts::Group", hunt.group,
        broadcast_message.to_json
      )
    end

    def device_broadcast!
      ServiceRunnerJob.perform_later(
        "DeviceBroadcasts::Device", device.id,
        broadcast_message.to_json,
        true
      )
    end

    def broadcast_message
      { type: "hunts", payload: { hunt_id: hunt.id, hunt_revision: hunt.revision } }
    end
  end
end
