# Adding HIBP API Token
class HibpAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?
    credential, new_record = generate_credential
    if save_credential(credential)
      ServiceRunnerJob.perform_later("Hibp::Services::PullBreaches", credential, true, new_record)
      flash[:notice] = "Configuration update for HIBP succeeded"
    else
      flash[:error] = "Configuration update for Hibp failed"
    end
    redirect_to account_integrations_path(current_account, { anchor: "dark_web" })
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::Hibp.find_by(account_id: params[:customer_id].to_i)
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to account_integrations_path(current_account, anchor: "dark_web")
  end

  private

  def connection_test
    api_key = params["hibp_api_key"] || params["access_token"]
    api_key = current_account.hibp_credential.hibp_api_key if helpers.masked?(api_key)
    Hibp::Services::ConnectionTest.new({ access_token: api_key }).call
  end

  def save_credential(credential)
    credential.save
  end

  def generate_credential
    token = Credentials::Hibp.where(account_id: current_account.id).first_or_initialize
    token.assign_attributes(hibp_api_key: params[:hibp_api_key]) if token.new_record?
    token.emails = params.permit(emails: {})[:emails].to_h.each_with_object({}) do |(k, v), h|
      h[k] = v.split("\r\n") if v.present?
      h
    end

    token.domains = params.permit(domains: {})[:domains].to_h.each_with_object({}) do |(k, v), h|
      h[k] = v.split("\r\n") if v.present?
      h
    end
    [token, token.new_record?]
  end
end
