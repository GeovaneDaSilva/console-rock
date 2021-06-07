module DeviceMessages
  # Processes log messages sent by a device
  class Heartbeat < Base
    def call
      device.assign_attributes(connectivity: :online) unless device.isolated?
      device.update(connectivity_updated_at: DateTime.current)

      Broadcasts::Devices::Status.new(device).call
    end
  end
end
