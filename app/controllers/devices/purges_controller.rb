module Devices
  # Queue Devices::Purge Polled Task
  class PurgesController < AuthenticatedController
    def create
      authorize device, :purge?

      respond_to do |format|
        format.js do
          @job_id = PolledTaskRunner.new.call("Devices::Purge", device)
                                    .key.split("/").last

          render partial: "devices/purge"
        end
      end
    end

    private

    def device
      @device ||= current_account.all_descendant_devices
                                 .find(params[:device_id].downcase)
    end
  end
end
