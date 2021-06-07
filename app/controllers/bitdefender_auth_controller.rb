# Adding Bitdefender API Token
class BitdefenderAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    opts = {}
    credential, first_pull = generate_token

    if first_pull && credential.save
      pull_companies(credential)
      opts = { show_app_id: app_id }
      flash[:notice] = "Configuration update for Bitdefender succeeded"
    elsif !first_pull
      save_antivirus_customer_map
      run_first_pulls(credential)
      flash[:notice] = "Configuration update for Bitdefender succeeded"
    else
      flash[:error] = "Configuration update for Bitdefender failed"
    end

    redirect_to account_integrations_path(current_account, opts.merge({ anchor: "antivirus" }))
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::Bitdefender.where(account_id: params[:customer_id].to_i).first
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to account_integrations_path(current_account, anchor: "antivirus")
  end

  private

  def connection_test
    access_token = params["access_token"]
    access_token = current_account.bitdefender_credential.access_token if helpers.masked?(access_token)
    Bitdefender::Services::ConnectionTest.new({ access_token: access_token }).call
  end

  def pull_companies(credential)
    Bitdefender::Services::PullCompanies.new(credential).call
  end

  def save_antivirus_customer_map
    (params["map"] || {}).each do |company_id, v|
      opts = { antivirus_id: company_id, app_id: app_id }
      record = AntivirusCustomerMap.where(opts).first_or_initialize

      if record.new_record?
        record.update(account_id: v["account_id"]) if v["account_id"].present?
      elsif v["account_id"].blank?
        record.destroy
      else
        record.update(account_id: v["account_id"])
      end
    end
  end

  def run_first_pulls(credential)
    ServiceRunnerJob.set(queue: "utility").perform_later(
      "Bitdefender::Services::Pull", credential, "quarantine_computers"
    )
    ServiceRunnerJob.set(queue: "utility").perform_later(
      "Bitdefender::Services::Pull", credential, "quarantine_exchange"
    )
  end

  def generate_token
    cred = Credentials::Bitdefender.where(account_id: current_account.id).first_or_initialize
    return [cred, false] unless cred.new_record?

    url = params[:bitdefender_url]
    url = Credentials::Bitdefender::DEFAULT_URL unless url.presence
    unless params[:access_token].nil?
      cred.assign_attributes(
        access_token:    params[:access_token],
        bitdefender_url: url,
        account_id:      current_account.id
      )
    end
    [cred, true]
  end

  def app_id
    @app_id ||= App.find_by(configuration_type: "bitdefender")&.id
  end
end
