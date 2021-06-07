# Broacast the device's status for an hunt revision
class DeviceHuntChannel < ApplicationCable::Channel
  def subscribed
    authorize device, :show?
    super

    stream_from channel_name
  end

  private

  def channel_name
    if revision.blank?
      "device_#{device.id}:hunt_#{hunt.id}"
    else
      "device_#{device.id}:hunt_#{hunt.id}_#{revision}"
    end
  end

  def device
    @device ||= Device.find(params[:device_id])
  end

  def hunt
    @hunt ||= Hunt.find(params.fetch(:id, nil))
  end

  def revision
    params["revision"]
  end
end
