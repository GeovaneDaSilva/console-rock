module DeviceMessages
  # Processes log messages sent by a device
  class Log < Base
    def call
      return unless payload

      log = device.logs.create(
        payload: payload, created_at: timestamp, updated_at: timestamp
      )

      Broadcasts::Devices::Logs.new(device, log).call
      alert_for_monitored!

      log
    end

    private

    def alert_for_monitored!
      return unless ENV["DEVICE_LOG_MONITOR_REGEX"]
      return unless Regexp.new(ENV["DEVICE_LOG_MONITOR_REGEX"], Regexp::IGNORECASE) =~ payload

      Rails.logger.tagged("DeviceLog") do
        Rails.logger.error %(device_id=#{device.id} log="#{payload}")
      end
    end
  end
end
