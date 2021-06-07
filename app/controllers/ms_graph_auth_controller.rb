require "jwt"
require "httpi"

# OAuth Authentication to MS Graph
class MsGraphAuthController < AuthenticatedController
  def signin
    authorize current_account, :can_manage_apps?

    @customer_id = params[:customer_id] unless params[:customer_id].nil?
    client_id = I18n.locale == :barracudamsp ? ENV["BARRACUDA_AZURE_APP_ID"] : ENV["AZURE_2FA_APP_ID"]

    hash = {
      client_id:    client_id,
      redirect_uri: auth_callback_url,
      state:        @customer_id
    }

    redirect_to URI::HTTPS.build(host: "login.microsoftonline.com", path: "/common/adminconsent",
      query: URI.encode_www_form(hash)).to_s
  end

  def signout
    authorize current_account, :can_manage_apps?
    credential = Credentials::MsGraph.where(customer_id: params[:customer_id].to_i).first

    if credential.nil?
      flash[:error] = "Failure to find associated credential"
    else
      ServiceRunnerJob.perform_later("Credentials::Destroy", credential.id)
      flash[:notice] = "Account removal initiated.  This may take a long time if there are many app results"
    end

    # redirect_to root_url
    redirect_to account_integrations_path(current_account, anchor: "microsoft")
  end

  def callback
    authorize current_account, :office365_apps_enabled_in_tree?
    @customer_id = params[:state].to_i
    success = nil
    success = save_in_session(params[:tenant]) if params[:error].nil?

    if success.nil?
      flash[:error] = "Admin consent required to enable functionality"
    elsif success
      flash[:notice] = "Successfully added Office 365 account"
    else
      flash[:error] = "Problem saving credential"
    end

    # redirect_to root_url
    redirect_to account_integrations_path(current_account, anchor: "microsoft")
  end

  private

  def save_in_session(tenant_id)
    return false unless params[:admin_consent]

    credential_to_save = Credentials::MsGraph.where(
      tenant_id: tenant_id, customer_id: @customer_id, account_id: @customer_id
    ).first_or_initialize
    return false unless credential_to_save.new_record?

    credential_to_save.assign_attributes(expiration: Time.zone.now)

    if credential_to_save.save
      ServiceRunnerJob.perform_later("MsGraph::Services::FirstPull", credential_to_save.id)
      true
    else
      false
    end
  end
end
