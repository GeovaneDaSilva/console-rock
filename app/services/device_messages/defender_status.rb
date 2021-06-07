module DeviceMessages
  # Update device's defender status
  class DefenderStatus < Base
    def call
      return unless payload

      update_device_defender_health_status!

      device.defender_status.create(
        payload: payload
      )
    end

    private

    def update_device_defender_health_status!
      status_strings = payload.dig("product_status_strings")
      if status_strings.blank?
        device.defender_health_status_unknown!
      elsif Array.wrap(status_strings).include?("Healthy")
        device.defender_health_status_healthy!
      else
        device.defender_health_status_unhealthy!
      end
    end
  end
end
