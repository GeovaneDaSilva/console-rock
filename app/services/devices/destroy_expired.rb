module Devices
  # Destroy expired devices
  class DestroyExpired
    def call
      Customer.all.each do |customer|
        device_expiration = fetch_device_expiration(customer)
        expired_devices = fetch_expired_devices(customer, device_expiration)
        expired_devices.each do |device|
          ServiceRunnerJob.set(queue: :utility).perform_later("Devices::Destroy", device)
        end
      end
    end

    private

    def fetch_device_expiration(customer)
      customer&.setting&.device_expiration || customer&.provider&.setting&.device_expiration
    end

    def fetch_expired_devices(account, expiration)
      return [] unless expiration

      days_ago = expiration.days.ago.beginning_of_day
      account.devices.offline.where("last_connected_at < ?", days_ago)
    end
  end
end
