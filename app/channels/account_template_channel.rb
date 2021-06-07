# Account's template
class AccountTemplateChannel < ApplicationCable::Channel
  def subscribed
    authorize account, :show?
    return reject unless template

    super

    stream_from channel_name

    Broadcasts::Accounts::Template.new(account, template).call
  rescue Pundit::NotAuthorizedError
    logger.info "Unauthorized #{template} request by User: #{user.id} to Account: #{account.id}"
  end

  private

  def channel_name
    "account:#{account.id}:#{template}"
  end

  def template
    params[:template] if Broadcasts::Accounts::Template::VALID_TEMPLATES.include?(params[:template])
  end

  def account
    @account ||= Account.find(params[:id])
  end
end
