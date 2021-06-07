# Adding Ironscales API Token
class IronscalesAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    # if connection_test[:code] == 200
    #   opts = authenticate
    # else
    #   flash[:error] = "Configuration update for Ironscales failed due to invalid credentials"
    # end
    opts = authenticate

    redirect_to account_integrations_path(current_account, opts.merge({ anchor: "email_security" }))
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::Ironscales.find_by(account_id: params[:account_id].to_i)
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to account_integrations_path(current_account, anchor: "antivirus")
  end

  private

  def authenticate
    opts = {}
    credential, first_pull = generate_credential

    if first_pull
      pull_companies(credential)
      opts = { show_app_id: Apps::IronscalesApp.first.id }
      flash[:notice] = "Configuration update for Ironscales succeeded"
    elsif !first_pull
      save_antivirus_customer_map
      ServiceRunnerJob.perform_later("Ironscales::Services::Runner", credential)
      flash[:notice] = "Map saved"
    else
      flash[:error] = "Configuration update for Ironscales failed"
    end
    opts
  end

  def connection_test
    refresh_token = params["refresh_token"]
    refresh_token = current_account.ironscales_credential.refresh_token if helpers.masked?(refresh_token)
    Ironscales::Services::ConnectionTest.new({ refresh_token: refresh_token }).call
  end

  def pull_companies(credential)
    Ironscales::Services::PullCompanies.new(credential).call
  end

  def save_antivirus_customer_map
    app_id = Apps::IronscalesApp.first.id
    (params["map"] || []).each do |ironscales_id, v|
      opt = { account_id: v["account_id"], antivirus_id: ironscales_id, app_id: app_id }
      check_opt = { antivirus_id: ironscales_id, app_id: app_id }
      record = AntivirusCustomerMap.where(check_opt).first

      if record.present?
        if v["account_id"].blank?
          record.destroy
          next
        end
        record.update(account_id: v["account_id"]) if record.account_id.to_s != v["account_id"]
      else
        next if v["account_id"].blank?

        AntivirusCustomerMap.create opt
      end
    end
  end

  def generate_credential
    token = Credentials::Ironscales.where(account_id: current_account.id).first_or_initialize
    new_record = token.new_record?
    if new_record
      token.assign_attributes(
        refresh_token:  params[:refresh_token],
        company_name:   params[:company_name],
        company_domain: params[:company_domain]
      )
      token.save
    end
    [token, new_record]
  end
end
