module R
  # Base controller for account reports
  class BaseController < AuthenticatedController
    layout "reports"

    private

    # Override the find_current_provider method from auth controller
    # Done to accomidate viewing resports as an customer user
    def find_current_provider
      provider = if current_account&.provider?
                   current_account
                 elsif current_account&.customer?
                   current_account.provider
                 end

      provider
    end
  end
end
