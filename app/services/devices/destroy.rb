module Devices
  # Service that triggers destroy for Devices
  class Destroy
    def initialize(key_or_device, device = nil)
      if key_or_device.is_a?(Device)
        @device = key_or_device
      else
        @key = key_or_device
        @device = device
      end
    end

    def call
      DatabaseTimeout.timeout(0) do
        @device.inventory_upload.tap(&:trashed!) if @device.inventory_upload
        @device.inventory_upload_id = nil

        @device.app_results.find_each(&:destroy)
        @device.hunt_results.find_each(&:destroy)

        @device.destroy!

        ServiceRunnerJob.set(queue: :utility).perform_later(
          "DeviceBroadcasts::Device",
          @device.id, { type: "agent_uninstall", payload: {} }.to_json, true
        )

        Rails.cache.write(@key, "completed") if @key
      end
    end
  end
end
