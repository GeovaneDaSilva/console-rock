# :nodoc
class CysuranceController < AuthenticatedController
  include ProviderHelper

  def create
    authorize(current_provider, :manage_cysurance?)
    response, _cysurance = Cysurance::Protect.new(account, app, options).call

    if response.is_a?(Hash) && response["STATUS_FLAG"] != 200
      flash[:error] = "Cysurance error: #{response['RESPONSE']}"
    else
      flash[:notice] = response
    end

    redirect_to root_path
  end

  def destroy
    authorize(current_provider, :manage_cysurance?)

    app_result = Apps::CysuranceResult.where(account_path: account.path).first
    opts = app_result&.details&.attributes
    if opts
      opts["cancel_yn"] = "Y"
      response, _cysurance = Cysurance::Protect.new(account, app, opts).call
      if response.is_a?(Hash) && response["STATUS_FLAG"] != 200
        flash[:error] = "Cysurance error: #{response['RESPONSE']}"
      else
        app_result.destroy
        flash[:notice] = response
      end
    else
      flash[:notice] = "No Protect Cysurance to cancel."
    end

    redirect_to root_path
  end

  def download_pdf
    authorize(current_provider, :manage_cysurance?)

    send_file(
      Rails.root.join("public", "Cysurance.pdf"),
      filename: "CysuranceRansomProtect.pdf",
      type:     "application/pdf"
    )
  end

  private

  def app
    @app ||= Apps::CysuranceApp.first
  end

  def account
    @account ||= Account.find params[:account_id]
  end

  # rubocop:disable Metrics/MethodLength
  def options
    res = {}
    %w[in_name eff_date partner_code in_company_name in_contact_phone in_email
       in_address1 in_address2 in_zip coverage_limit in_country
       policy_type premium conf_email_yn show_price_yn cancel_yn].each do |key|
      case key
      when "in_country"
        symbol = params[key] == "US" ? "us" : "ca"
        res["in_state"] = params["state_#{symbol}"]
        res["in_city"] = ISO3166::Country.new(symbol).states[res["in_state"]].name
        res["country_code"] = params[key]
        res[key] = params[key]
      when "conf_email_yn", "show_price_yn", "cancel_yn"
        res[key] = params[key] == "true" ? "Y" : "N"
      when "premium", "coverage_limit"
        val = params[key]
        val[0] = ""
        res[key] = val
      else
        res[key] = params[key]
      end
    end
    res
  end
  # rubocop:enable Metrics/MethodLength
end
