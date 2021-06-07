module DeviceMessages
  # Processes hash progress messages
  class HashProgress < Base
    def call
      device.hash_progress = payload.dig("progress")

      Broadcasts::Devices::Status.new(device).call
    end
  end
end
