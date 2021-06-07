# Adding SentinelOne API Token
class SentineloneAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    opts = {}
    credential, first_pull = generate_token

    if first_pull && credential.save
      pull_companies(credential)
      opts = { show_app_id: app_id }
      flash[:notice] = "Configuration update for SentinelOne succeeded"
    elsif !first_pull
      save_antivirus_customer_map
      run_first_pulls(credential)
      flash[:notice] = "Configuration update for SentinelOne succeeded"
    else
      flash[:error] = "Configuration update for SentinelOne failed"
    end

    redirect_to account_integrations_path(current_account, opts.merge({ anchor: "antivirus" }))
  end

  def destroy
    authorize current_account, :can_manage_apps?

    token = Credentials::Sentinelone.find_by(account_id: current_account.id)
    if token.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", token.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to account_integrations_path(current_account, anchor: "antivirus")
  end

  private

  def connection_test
    api_token = params["api_token"] || params["sentinelone_api_token"]
    api_token = current_account.sentinelone_credential&.access_token if helpers.masked?(api_token)
    Sentinelone::Services::ConnectionTest.new({ api_token: api_token }).call
  end

  def pull_companies(credential)
    Sentinelone::Services::Pull.new(credential, "companies",
                                    { once_only: true, "state" => "active",
                                      "sortBy" => "name", "limit" => "500" }).call
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
    ServiceRunnerJob.perform_later("Sentinelone::Services::Pull", credential, "threats")
    ServiceRunnerJob.perform_later("Sentinelone::Services::Pull", credential, "user_info")
  end

  def generate_token
    cred = Credentials::Sentinelone.where(account_id: current_account.id).first_or_initialize
    return [cred, false] unless cred.new_record?

    unless params[:sentinelone_api_token].nil?
      cred.assign_attributes(
        access_token:    params[:sentinelone_api_token],
        sentinelone_url: params[:sentinelone_url]
      )
    end
    [cred, true]
  end

  def app_id
    @app_id ||= App.find_by(configuration_type: "sentinelone")&.id
  end
end
