module Accounts
  module Apps
    module Incidents
      # Account app incidents
      class ResolvesController < AuthenticatedController
        def update
          authorize incident, :resolve?

          incident.state = :resolved
          incident.resolver = current_user

          if incident.save
            ::Incidents::Integrations.close_ticket(incident, account)
            flash[:notice] = "Incident ##{incident.id} has been resolved"
          else
            flash[:error] = "Unable to resolve incident ##{incident.id}"
          end

          redirect_to account_apps_incidents_path(account)
        end

        private

        def incident
          @incident ||= incidents.find(params[:incident_id])
        end

        def incidents
          policy_scope(account.all_descendant_incidents.order("state DESC, updated_at DESC"))
        end

        def account
          @account ||= policy_scope(Account).find(params[:account_id])
        end
      end
    end
  end
end
