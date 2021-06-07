# Account's defender stats
class AccountDefenderChannel < ApplicationCable::Channel
  def subscribed
    authorize account, :show?
    super

    stream_from channel_name

    Broadcasts::Accounts::Defender.new(account).call
  rescue Pundit::NotAuthorizedError
    logger.info "Unauthorized Defender request by User: #{user.id} to Account: #{account.id}"
  end

  def refresh
    super

    Broadcasts::Accounts::Defender.new(account).call
  end

  private

  def channel_name
    "account:#{account.id}:defender"
  end

  def account
    @account ||= Account.find(params[:account_id])
  end
end
