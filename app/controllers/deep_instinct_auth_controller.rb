# Adding DeepInstinct API Token
class DeepInstinctAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    opts = {}
    token = generate_token
    first_pull = token.new_record?

    if first_pull && save_token(token)
      pull_companies(token)
      opts = { show_app_id: Apps::DeepInstinctApp.first.id }
      flash[:notice] = "Configuration update for Deep Instinct succeeded"
    elsif !first_pull
      save_antivirus_customer_map
      ServiceRunnerJob.perform_later("DeepInstinct::Services::PullEvents", token)
      opts = {}
      flash[:notice] = "Map saved"
    else
      flash[:error] = "Configuration update for DeepInstinct failed"
    end

    redirect_to account_integrations_path(current_account, opts.merge({ anchor: "antivirus" }))
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::DeepInstinct.where(account_id: params[:customer_id].to_i).first
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to account_integrations_path(current_account, anchor: "antivirus")
  end

  private

  def save_token(token)
    token.save
  end

  def connection_test
    access_token = params["access_token"]
    access_token = current_account.deep_instinct_credential&.access_token if helpers.masked?(access_token)
    DeepInstinct::Services::ConnectionTest.new(
      { access_token: access_token, base_url: params[:base_url] }
    ).call
  end

  def pull_companies(credential)
    DeepInstinct::Services::PullTenants.new(credential).call
    DeepInstinct::Services::PullMsps.new(credential).call
  end

  def save_antivirus_customer_map
    app_id = Apps::DeepInstinctApp.first.id

    (params[:map] || []).each do |k, v|
      opt = { account_id: v["account_id"], antivirus_id: v["msp_id"] || v["tenant_id"], app_id: app_id }
      check_opt = { antivirus_id: k, app_id: app_id }

      record = AntivirusCustomerMap.where(check_opt).first
      if record.present?
        record.update(account_id: v["account_id"]) if record.account_id.to_s != v["account_id"]
      else
        AntivirusCustomerMap.create opt
      end
    end
  end

  def generate_token
    token = Credentials::DeepInstinct.where(account_id: current_account.id).first_or_initialize

    unless params[:access_token].nil?
      token.assign_attributes(access_token: params[:access_token], base_url: params[:base_url])
    end
    token
  end
end
