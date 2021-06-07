# Adding CiscoUmbrella API Token
class CiscoUmbrellaAuthController < AuthenticatedController
  def create
    authorize current_account, :can_manage_apps?

    cred = Credentials::CiscoUmbrella.where(customer: current_account,
                                            account:  current_account).first_or_initialize

    first_pull = cred.new_record?

    if options.values.reject { |e| e.to_s.empty? }.size == 2
      cred.assign_attributes(options)
      if cred.save
        flash[:notice] = "Configuration update for Cisco Umbrella succeeded"
        if first_pull
          ServiceRunnerJob.set(queue: "utility").perform_later(
            "CiscoUmbrella::Services::PullOrganizations", cred.id
          )
        end
      else
        flash[:error] = "Configuration update for CiscoUmbrella failed"
      end
    else
      flash[:error] = "Configuration update for CiscoUmbrella failed, empty values detected."
    end

    redirect_to root_url
  end

  def destroy
    authorize current_account, :can_manage_apps?

    cred = Credentials::CiscoUmbrella.where(account_id: params[:customer_id].to_i).first
    if cred.nil?
      flash[:error] = "No active credential found"
    else
      ServiceRunnerJob.set(queue: "utility").perform_later("Credentials::Destroy", cred.id)
      flash[:notice] = "Credential and all associated records queued for deletion"
    end

    redirect_to root_url
  end

  private

  def options
    {
      app_key:    params[:app_key],
      app_secret: params[:app_secret]
    }
  end
end
