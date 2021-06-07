# OAuth Authentication to DNSFilter
class DnsFilterAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    authenticate

    redirect_to account_integrations_path(current_account, anchor: "network")
  end

  def destroy
    authorize current_account, :can_manage_apps?

    credential = Credentials::DnsFilter.find_by(account_id: params[:customer_id].to_i)
    credential ||= Credentials::DnsFilter.find_by(customer_id: params[:customer_id].to_i)

    if credential.nil?
      flash[:error] = "Failure to find associated credential"
    else
      ServiceRunnerJob.perform_later("Credentials::Destroy", credential.id)
      flash[:notice] = "Account removal initiated.  This may take a long time if there are many app results"
    end

    redirect_to account_integrations_path(current_account, anchor: "network")
  end

  private

  def authenticate
    credential = Credentials::DnsFilter.where(account_id: current_account.id).first_or_initialize
    credential.assign_attributes(
      account_id:          current_account.id,
      dns_filter_username: params[:dns_filter_username],
      dns_filter_password: params[:dns_filter_password]
    )

    new_record = credential.new_record?
    new_record ? DnsFilter::Services::PullUserInfo.new(credential).call : save_antivirus_customer_map
    pull_top_domains(credential, new_record)
    flash[:notice] = "Configuration setup for DNS Filter succeeded"
  end

  def connection_test
    cred = params.permit!
    if helpers.masked?(cred["dns_filter_password"])
      c = current_account.dns_filter_credential
      cred = {
        account_id:          c.account_id,
        dns_filter_username: c.dns_filter_username,
        dns_filter_password: c.dns_filter_password
      }
    end
    DnsFilter::Services::ConnectionTest.new(cred).call
  end

  def pull_top_domains(credential, first_pull = false)
    opts = { from: 72.hours.ago.to_i, first_pull: first_pull }
    ServiceRunnerJob
      .set(queue: :utility)
      .perform_later("DnsFilter::Services::PullTopDomains", credential, opts)
  end

  def save_antivirus_customer_map
    app_id = Apps::DnsFilterApp.first.id
    (params["map"] || []).each do |_k, v|
      opt = { account_id: v["account_id"], antivirus_id: v["organization_id"], app_id: app_id }
      check_opt = { antivirus_id: v["organization_id"], app_id: app_id }

      record = AntivirusCustomerMap.where(check_opt).first
      if record.present?
        if v["account_id"].blank?
          record.delete
        elsif record.account_id.to_s != v["account_id"]
          record.update(account_id: v["account_id"])
        end
      else
        AntivirusCustomerMap.create opt
      end
    end
  end

  def app
    @app ||= App.find_by(configuration_type: "dns_filter")
  end

  def app_config
    @app_config ||= current_account.app_configs.find_or_initialize_by(app: app)
  end
end
