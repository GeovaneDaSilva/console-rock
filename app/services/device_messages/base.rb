module DeviceMessages
  # Base class for device messages
  class Base
    def initialize(message)
      @message = message
    end

    def call
      raise NotImplementedError
    end

    private

    def device
      @device ||= Device.find(@message["id"])
    rescue ActiveRecord::RecordNotFound
      # Rails.logger.info("Received message for device which does not exist #{@message['id']}")
      handle_device_not_found unless ENV["REVIEW_APP"] # See https://github.com/rocketcyber/console/issues/2031
      raise DeviceNotFoundError
    end

    def payload
      @payload ||= @message["payload"]
    end

    def timestamp
      @timestamp ||= Time.use_zone(device.timezone) { Time.zone.at(@message["timestamp"]).to_datetime }
    end

    def handle_device_not_found
      ServiceRunnerJob.perform_later(
        "DeviceBroadcasts::Device",
        @message["id"],
        { type: "agent_uninstall", payload: {} }.to_json
      )
    end
  end
end
