module Devices
  # Send app update ws message to all devices
  # Uses an advisory lock to ensure that only one job runs at a time
  # Notifies in batches to avoid a trampling herd
  class UpdateApps
    BATCH_SIZE = ENV.fetch("UPDATE_APPS_BATCH_SIZE", "100").to_i

    def initialize(offset = 0)
      @offset = offset
    end

    def call
      App.with_advisory_lock("app-update-notification", timeout_seconds: 0) do
        if device_ids.empty? # complete!
          Rails.cache.delete("app-update-notification")
        else
          device_ids.each do |device_id|
            DeviceBroadcasts::Device.new(device_id, message, true).call
          end

          total_count = Device.count.to_f
          completed   = @offset + BATCH_SIZE

          percentage = (completed / total_count * 100).to_i
          Rails.cache.write("app-update-notification", percentage, expires_in: 1.hour)

          ServiceRunnerJob.set(queue: :utility, wait: 10.seconds).perform_later(
            self.class.name, completed
          )
        end
      end
    end

    private

    def device_ids
      @device_ids ||= Device.order(:id).offset(@offset).limit(BATCH_SIZE).pluck(:id)
    end

    def message
      @message ||= { type: "apps", payload: {} }.to_json
    end
  end
end
