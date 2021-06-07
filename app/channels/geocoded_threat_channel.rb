# Subscribe to an account's geocoded threats
class GeocodedThreatChannel < ApplicationCable::Channel
  def subscribed
    authorize account, :show?
    super

    stream_from channel_name
  end

  private

  def channel_name
    "account_#{account.id}:geocoded_threats"
  end

  def account
    @account ||= Account.find(params[:id])
  end
end
