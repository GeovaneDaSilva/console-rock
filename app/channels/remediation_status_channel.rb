# Subscribe to a device's status
class RemediationStatusChannel < ApplicationCable::Channel
  def subscribed
    authorize remediation, :show?
    super

    stream_from channel_name
    sleep 0.1
    Broadcasts::Remediations::Status.new(remediation).call
  end

  def refresh
    super
    Broadcasts::Remediations::Status.new(remediation.reload).call
  end

  private

  def channel_name
    "remediation_#{remediation.id}:status"
  end

  def remediation
    @remediation ||= Remediation.find(params[:id])
  end
end
