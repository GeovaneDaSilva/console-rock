# Adding Passly API
class PasslyAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    opts = authenticate

    redirect_to account_integrations_path(current_account, opts.merge({ anchor: "mfa" }))
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::Passly.where(account_id: params[:customer_id].to_i).first
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to account_integrations_path(current_account, anchor: "mfa")
  end

  private

  def authenticate
    credential, first_pull = generate_credential
    opts = {}

    if first_pull
      pull_organizations(credential)
      opts = { show_app_id: Apps::PasslyApp.first.id }
      flash[:notice] = "Configuration update for Passly succeeded"
    elsif !first_pull
      save_antivirus_customer_map
      ServiceRunnerJob.set(queue: "utility").perform_later(
        "Passly::Services::PullAuditEntries", credential.id
      )
      flash[:notice] = "Map saved"
    else
      flash[:error] = "Configuration update for Passly failed"
    end
    opts
  end

  def connection_test
    cred = params
    if helpers.masked?(cred["app_secret"])
      c = current_account.passly_credential
      cred = {
        "tenant_id"  => c.tenant_id,
        "app_id"     => c.app_id,
        "app_secret" => c.app_secret
      }
    end
    Passly::Services::ConnectionTest.new(cred).call
  end

  def save_antivirus_customer_map
    app_id = Apps::PasslyApp.first.id
    (params["map"] || []).each do |organization_id, v|
      opt = { account_id: v["account_id"], antivirus_id: organization_id, app_id: app_id }
      check_opt = { antivirus_id: organization_id, app_id: app_id }
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

  def pull_organizations(credential)
    Passly::Services::PullOrganizations.new(credential).call
  end

  def generate_credential
    token = Credentials::Passly.where(account_id:  current_account.id,
                                      customer_id: current_account.id).first_or_initialize
    new_record = token.new_record?
    if new_record
      token.assign_attributes(options)
      token.save
    end
    [token, new_record]
  end

  def options
    {
      tenant_id:  params[:tenant_id],
      app_id:     params[:app_id],
      app_secret: params[:app_secret]
    }
  end
end
