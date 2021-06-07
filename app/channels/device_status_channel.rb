# Subscribe to a device's status
class DeviceStatusChannel < ApplicationCable::Channel
  def subscribed
    authorize device, :show?
    super

    stream_from channel_name
    sleep 0.1
    Broadcasts::Devices::Status.new(device).call
  end

  def refresh
    super
    Broadcasts::Devices::Status.new(device.reload).call
  end

  private

  def channel_name
    "device_#{device.id}:status"
  end

  def device
    @device ||= Device.find(params[:id])
  end
end
