# Broacast the device logs
class DeviceLogsChannel < ApplicationCable::Channel
  def subscribed
    authorize device, :show?
    super

    stream_from channel_name
    sleep 0.1
    Broadcasts::Devices::Logs.new(device).call
  end

  private

  def channel_name
    "device_#{device.id}:logs"
  end

  def device
    @device ||= Device.find(params[:id])
  end
end
