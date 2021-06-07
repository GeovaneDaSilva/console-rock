# OAuth Authentication for Sophos
class SophosAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    authenticate
    opts = { show_app_id: Apps::SophosApp.first.id }

    redirect_to account_integrations_path(current_account, opts.merge({ anchor: "antivirus" }))
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::Sophos.where(account_id: params[:customer_id].to_i).first
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    opts = { show_app_id: Apps::SophosApp.first.id }
    redirect_to account_integrations_path(current_account, opts.merge({ anchor: "antivirus" }))
  end

  private

  def authenticate
    credential = Credentials::Sophos.where(account_id: current_account.id).first_or_initialize
    credential.assign_attributes(
      account_id:           current_account.id,
      sophos_client_id:     params[:sophos_client_id],
      sophos_client_secret: params[:sophos_client_secret]
    )

    new_record = credential.new_record?

    if new_record
      Sophos::Services::PullCallerInfo.new(credential).call
      Sophos::Services::PullTenants.new(credential).call
    else
      save_antivirus_customer_map
      ServiceRunnerJob.set(queue: "utility").perform_later("Sophos::Services::PullAlerts", credential)
    end

    flash[:notice] = "Configuration update for Sophos succeeded"
  end

  def connection_test
    authorize current_account, :can_manage_apps?

    cred = params
    if helpers.masked?(cred[:sophos_client_id])
      c = current_account.sophos_credential
      cred = {
        sophos_client_id:     c.sophos_client_id,
        sophos_client_secret: c.sophos_client_secret
      }
    end

    Sophos::Services::ConnectionTest.new(
      account_id:           current_account.id,
      sophos_client_id:     cred[:sophos_client_id],
      sophos_client_secret: cred[:sophos_client_secret]
    ).call
  end

  def save_antivirus_customer_map
    app_id = Apps::SophosApp.first.id
    (params[:map] || []).each do |k, v|
      record = AntivirusCustomerMap.where(antivirus_id: k, app_id: app_id).first_or_initialize
      record.update(account_id: v["account_id"])
    end
  end
end
