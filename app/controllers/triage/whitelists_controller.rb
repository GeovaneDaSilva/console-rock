module Triage
  # Account level whitelisting of app results
  class WhitelistsController < AuthenticatedController
    include Triagable
    include Whitelistable

    private

    def scope
      account
    end

    def app_results
      if incident?
        results = incident.results
        results = results.where(id: params[:app_results])
        results = results.where(incident_id: params[:incident_id])
        results
      else
        account.all_descendant_app_results
      end
    end

    def account
      Account.find(params[:account_id])
    end

    def triage_path(*opts)
      account_triage_path(account, *opts)
    end

    def whitelist_path(*opts)
      account_triage_whitelist_path(account, *opts)
    end
  end
end
