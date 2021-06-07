module Accounts
  module Apps
    module Incidents
      # Account app incidents
      class PublishesController < AuthenticatedController
        helper_method :triage_path

        def update
          authorize incident, :publish?

          if account.managed? && account.setting.auto_remediate && remediations?
            redirect_to account_apps_incident_remediate_path(account, incident)
            return
          elsif incident.published!
            ::Incidents::Integrations.create_ticket(incident)
            flash[:notice] = "Incident ##{incident.id} has been published"
          else
            flash[:error] = "Unable to publish incident ##{incident.id}"
          end

          redirect_to account_apps_incident_path(account, incident)
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

        def remediations?
          (incident.remediation_plan&.remediations&.count || 0).positive?
        end

        def triage_path(*opts)
          account_triage_path(account, *opts)
        end
      end
    end
  end
end
