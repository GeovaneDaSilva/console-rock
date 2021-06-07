# Broadcast app results and devices for an app reflecting all devices for an account
class AppsChannel < ApplicationCable::Channel
  def subscribed
    authorize scope_account, :show?
    super

    stream_from channel_name

    Broadcasts::Accounts::Apps.new(app, scope_account).call
  rescue Pundit::NotAuthorizedError
    logger.info "Unauthorized Account Apps request by User: #{user.id} to Account: #{account.id}"
  end

  def refresh
    super

    Broadcasts::Accounts::Apps.new(app.reload, scope_account.reload).call
  end

  private

  def channel_name
    "app:#{app.id}:#{scope_account.id}"
  end

  def app
    @app ||= App.find(params[:app_id])
  end

  def scope_account
    @scope_account ||= Account.find(params[:scope_account_id])
  end
end
