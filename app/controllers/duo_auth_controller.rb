# Adding Duo API Token
class DuoAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?
    token = generate_token

    first_pull = token.new_record?
    if save_token(token)
      if first_pull
        ServiceRunnerJob.set(queue: "utility").perform_later(
          "Duo::Services::PullAdminLogs", token
        )
        ServiceRunnerJob.set(queue: "utility").perform_later(
          "Duo::Services::PullAuthLogs", token
        )
        ServiceRunnerJob.set(queue: "utility").perform_later(
          "Duo::Services::PullRetrieveEvents", token
        )
      end
      flash[:notice] = "Configuration update for Duo succeeded"
    else
      flash[:error] = "Configuration update for Duo failed"
    end

    redirect_to account_integrations_path(current_account, anchor: "email_security")
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::Duo.where(account_id: params[:customer_id].to_i).first
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to account_integrations_path(current_account, anchor: "email_security")
  end

  private

  def save_token(token)
    token.save
  end

  def connection_test
    cred = { duo_host:            params["duo_host"],
             duo_secret:          params["duo_secret"],
             duo_integration_key: params["duo_integration_key"],
             account_id:          params["account_id"] }

    if helpers.masked?(cred["duo_secret"])
      c = current_account.duo_credential
      cred = {
        "duo_host"            => c.duo_host,
        "duo_secret"          => c.duo_secret,
        "duo_integration_key" => c.duo_integration_key
      }
    end
    Duo::Services::ConnectionTest.new(cred).call
  end

  def generate_token
    token = Credentials::Duo.where(account_id: current_account.id).first_or_initialize
    token.assign_attributes(
      duo_host:            params[:duo_host],
      duo_secret:          params[:duo_secret],
      duo_integration_key: params[:duo_integration_key]
    )
    token.assign_attributes(account_id: current_account.id) if current_account.customer?
    token
  end
end
