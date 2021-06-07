# Subscribe to a firewall's count
class FirewallCountChannel < ApplicationCable::Channel
  def subscribed
    authorize account, :show?
    super

    stream_from channel_name

    Broadcasts::FirewallCount::Status.new(account).call
  end

  private

  def channel_name
    "firewall_count_#{account.id}:status"
  end

  def account
    @account ||= Account.find(params[:id])
  end
end
