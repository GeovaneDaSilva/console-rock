module Triage
  # Account level incident creation of app results
  class IncidentsController < AuthenticatedController
    include Triagable
    include Incidentable

    private

    def scope
      account
    end

    def app_results
      account.all_descendant_app_results
    end

    def app_counter_caches
      account.all_descendant_app_counter_caches.where(app: app)
    end

    def account
      Account.find(params[:account_id])
    end

    def triage_path(opts = {})
      account_triage_path(account, opts.merge(app_id: app.id))
    end

    def incident_path(opts = {})
      account_triage_incident_path(account, opts)
    end
  end
end
