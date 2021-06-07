# OAuth Authentication to Webroot
class WebrootAuthController < AuthenticatedController
  include ErrorHelper

  WEBROOT_AUTH_ENDPOINT = "https://unityapi.webrootcloudav.com/auth/token".freeze

  def create
    authorize current_account, :can_manage_apps?

    opts = authenticate

    redirect_to account_integrations_path(current_account, opts.merge({ anchor: "antivirus" }))
  end

  def destroy
    authorize current_account, :can_manage_apps?

    credential = Credentials::Webroot.find_by(account_id: params[:customer_id].to_i)
    credential ||= Credentials::Webroot.find_by(customer_id: params[:customer_id].to_i)

    if credential.nil?
      flash[:error] = "Failure to find associated credential"
    else
      ServiceRunnerJob.perform_later("Credentials::Destroy", credential.id)
      flash[:notice] = "Account removal initiated.  This may take a long time if there are many app results"
    end

    redirect_to account_integrations_path(current_account, anchor: "antivirus")
  end

  private

  def connection_test
    cred = params.permit!
    if helpers.masked?(cred[:webroot_client_secret])
      c = current_account.webroot_credential
      cred = {
        webroot_username:          c.webroot_username,
        webroot_password:          c.webroot_password,
        webroot_basic_auth_string: c.webroot_basic_auth_string,
        webroot_gsm_key:           c.webroot_gsm_key
      }
    end
    Webroot::Services::ConnectionTest.new(cred).call
  end

  def authenticate
    credential, first_pull = generate_credential
    opts = {}

    if first_pull && credential&.save
      pull_organizations(credential)
      opts = { show_app_id: app.id }
      flash[:notice] = "Configuration update succeeded"
    elsif !first_pull
      save_antivirus_customer_map
      run_pull_helper(credential)
      flash[:notice] = "Map saved"
    else
      flash[:error] = "Configuration save failed"
    end
    opts
  end

  def save_antivirus_customer_map
    app_id = app.id
    (params["map"] || {}).each do |organization_id, v|
      opts = { antivirus_id: organization_id, app_id: app_id }
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

  def generate_credential
    cred = Credentials::Webroot.where(account_id: params[:customer_id].to_i).first_or_initialize
    return [cred, false] unless cred.new_record?

    basic_auth_string = Base64.encode64("#{params[:webroot_client_id]}:#{params[:webroot_client_secret]}")
                              .delete("\n")

    headers = { Authorization: "Basic #{basic_auth_string}" }
    body = {
      username:   params[:webroot_username],
      password:   params[:webroot_password],
      grant_type: "password",
      scope:      ENV["WEBROOT_SCOPES"]
    }

    request = HTTPI::Request.new
    request.url = WEBROOT_AUTH_ENDPOINT
    request.headers = headers
    request.body = body
    resp = HTTPI.post(request)
    return [nil, true] if html_error(__FILE__, resp, params[:customer_id])

    save(resp, basic_auth_string)
  end

  def save(resp, basic_auth_string)
    data = JSON.parse(resp.raw_body)

    cred = Credentials::Webroot.where(account_id: params[:customer_id].to_i).first_or_initialize
    return [cred, false] if !cred.new_record? || cred.webroot_gsm_key == params[:webroot_gsm_key]

    cred.assign_attributes(
      expiration:                DateTime.current + data["expires_in"].seconds,
      access_token:              data["access_token"],
      refresh_token:             data["refresh_token"],
      webroot_basic_auth_string: basic_auth_string,
      webroot_gsm_key:           params[:webroot_gsm_key],
      webroot_password:          params[:webroot_password],
      webroot_username:          params[:webroot_username]
    )
    # cred.assign_attributes(customer_id: params[:customer_id]) if current_account.customer?

    # cred.save ? first_pull(cred) : false
    [cred, true]
  end

  def pull_organizations(credential)
    Webroot::Services::PullSites.new(credential.id).call
  end

  def run_pull_helper(cred)
    return if cred.id.nil?

    params = {
      start_date: (3.months.ago + 1.day).utc.iso8601,
      cred_id:    cred.id
    }
    ServiceRunnerJob.perform_later("Webroot::Services::PullHelper", params)
    true
  end

  def app
    @app ||= App.find_by(configuration_type: "webroot")
  end

  def app_config
    @app_config ||= current_account.app_configs.find_or_initialize_by(app: app)
  end
end
