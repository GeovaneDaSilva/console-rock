# Broacast the device's job status
class DeviceJobChannel < ApplicationCable::Channel
  def subscribed
    authorize device, :show?
    super

    stream_from channel_name
  end

  private

  def channel_name
    "device_#{device.id}:job_#{job.id}"
  end

  def job
    @job ||= Job.where(account: device.customer.root.self_and_all_descendants)
                .find(params[:job_id])
  end

  def device
    @device ||= Device.find(params[:device_id])
  end
end
