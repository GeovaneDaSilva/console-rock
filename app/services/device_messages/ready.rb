module DeviceMessages
  # A device is ready to rumble
  # Indicates new startup
  class Ready < Base
    def call
      DeviceBroadcasts::Device.new(
        device.id,
        { type: "hunts", payload: {} }.to_json
      ).call

      DeviceBroadcasts::Device.new(
        device.id,
        { type: "apps", payload: {} }.to_json
      ).call
    end
  end
end
