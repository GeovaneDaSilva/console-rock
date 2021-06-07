module Accounts
  #  Allow for customer import from PSA
  class PsaCustomerCreationController < AuthenticatedController
    helper_method :psa_config, :new_companies

    def index
      authorize account, :can_manage_integrations?
    end

    def create
      authorize account, :can_manage_integrations?

      if account.customer?
        flash[:error] = "You are integrating a PSA/importing companies under a customer rather than the MSP."
        redirect_back fallback_location: account_integrations_path(account)
      end

      ServiceRunnerJob.perform_later("Integrations::CreateCustomers", params[:companies].permit!, psa_config)
      if params[:companies].nil?
        flash[:error] = "Problem creating companies"
      else
        flash[:notice] = "Companies are being created."
      end

      redirect_to account_integrations_path(account)
    end

    private

    def new_companies
      @new_companies ||= psa_config.companies
    end

    def account
      @account ||= Account.find(params[:account_id])
    end

    def psa_config
      @psa_config ||= account.psa_config
    end
  end
end
