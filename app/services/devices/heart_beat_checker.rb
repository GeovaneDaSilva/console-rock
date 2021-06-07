module Devices
  # Check for devices which haven't had their heartbeat updated within the last 8 minutes
  # Update as offline
  class HeartBeatChecker
    def call
      wait_seconds = 480 # 60 * 8 = 8 minutes
      stale_devices.find_each do |device|
        wait_time = rand(1..wait_seconds)
        ServiceRunnerJob.set(queue: :utility, wait: wait_time.seconds).perform_later(
          "DeviceMessages::Connection",
          "id"        => device.id,
          "type"      => "disconnected",
          "timestamp" => Time.use_zone(device.timezone) { DateTime.current }.to_f
        )
      end
    end

    private

    def stale_devices
      Device.online.where("connectivity_updated_at < ?", 18.minutes.ago) # missed two heartbeats
    end
  end
end
