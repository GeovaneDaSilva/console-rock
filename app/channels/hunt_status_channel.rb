# Subscribe to a hunt's status
class HuntStatusChannel < ApplicationCable::Channel
  def subscribed
    authorize hunt.group, :show?
    super

    stream_from channel_name
    Broadcasts::Hunts::Status.new(hunt).call
  end

  private

  def channel_name
    "hunt_#{hunt.id}:status"
  end

  def hunt
    @hunt ||= Hunt.find(params[:id])
  end
end
