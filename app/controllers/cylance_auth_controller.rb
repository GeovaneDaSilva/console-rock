# Adding Cylance API Token
class CylanceAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    # if connection_test[:code] == 200
    #   authenticate
    # else
    #   flash[:error] = "Configuration update for Cylance failed due to invalid credentials"
    # end
    cred = authenticate
    @account_id = cred.customer_id || cred.account_id

    respond_to do |format|
      format.js
      format.html { redirect_to account_integrations_path(current_account, anchor: "antivirus") }
    end
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::Cylance.where(customer_id: params[:customer_id].to_i)
                               .or(Credentials::Cylance.where(account_id: params[:customer_id].to_i)).first
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to account_integrations_path(current_account, anchor: "antivirus")
  end

  private

  def customer
    @customer ||= Customer.find(params[:customer_id])
  rescue ActiveRecord::RecordNotFound
    @customer ||= current_account
  end

  def credential
    @credential ||= Credentials::Cylance.find(params[:credential_id])
  rescue ActiveRecord::RecordNotFound
    @credential ||= Credentials::Cylance.where(account_id: customer.id).first_or_initialize
  end

  def authenticate
    cred = credential
    first_pull = cred.new_record?

    if options(cred).values.reject { |e| e.to_s.empty? || e.to_s.include?("*") }.size == 4
      cred.assign_attributes(options(cred).merge({ account_id: customer.id, customer_id: customer.id }))
      if cred.save
        flash[:notice] = "Configuration update for Cylance succeeded"
        if first_pull
          ServiceRunnerJob.set(queue: "utility").perform_later(
            "Cylance::Services::PullThreats", cred.id
          )
        end
      else
        flash[:error] = "Configuration update for Cylance failed"
      end
    else
      flash[:error] = "Configuration update for Cylance failed, empty values detected."
    end
    cred
  end

  def connection_test(cred)
    Cylance::Services::ConnectionTest.new(options(cred)).call
  end

  def options(cred)
    if helpers.masked?(cred[:app_secret])
      c = current_account.cylance_credential
      {
        tenant_id:          c.tenant_id,
        cylance_app_id:     c.app_id,
        cylance_app_secret: c.app_secret,
        base_url:           c.base_url
      }
    else
      {
        tenant_id:          params[:tenant_id],
        cylance_app_id:     params[:app_id] || params[:cylance_app_id],
        cylance_app_secret: params[:app_secret] || params[:cylance_app_secret],
        base_url:           params[:base_url]
      }
    end
  end
end
