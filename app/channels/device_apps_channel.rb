# Broadcast app results for a specifc device
class DeviceAppsChannel < ApplicationCable::Channel
  def subscribed
    authorize device, :show?
    super

    stream_from channel_name
    sleep 0.1
    Broadcasts::Devices::Apps.new(app, device).call
  end

  def refresh
    super

    Broadcasts::Devices::Apps.new(app.reload, device.reload).call
  end

  private

  def channel_name
    "device_apps:#{app.id}:#{device.id}"
  end

  def app
    @app ||= App.find(params[:app_id])
  end

  def device
    @device ||= Device.find(params[:device_id])
  end
end
