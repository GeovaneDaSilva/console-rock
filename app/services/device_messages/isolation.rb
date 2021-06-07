module DeviceMessages
  # Isolate or Un-Isolate a device
  class Isolation < Base
    def call
      case @message.dig("payload", "status")
      when "success"
        update_device
      when "failure"
        Rails.logger.warn(
          "Isolation message - Failed to #{@message.dig('type')} device #{@message.dig('id')}"
        )
      else
        Rails.logger.error("Isolation message - unsupported status #{@message}")
      end
    end

    private

    def update_device
      if @message.dig("type") == "isolate"
        device.update(connectivity: :isolated)
      elsif @message.dig("type") == "restore"
        device.update(connectivity: :online)
      end
      Broadcasts::Devices::Status.new(device).call
    end
  end
end
