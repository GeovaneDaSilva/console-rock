# Account's device connectivity
class AccountMailboxesChannel < ApplicationCable::Channel
  def subscribed
    authorize account, :show?
    super

    stream_from channel_name

    Broadcasts::Accounts::Mailboxes.new(account).call
  rescue Pundit::NotAuthorizedError
    logger.info "Unauthorized Mailbox request by User: #{user.id} to Account: #{account.id}"
  end

  private

  def channel_name
    "account:#{account.id}:mailboxes"
  end

  def account
    @account ||= Account.find(params[:id])
  end
end
