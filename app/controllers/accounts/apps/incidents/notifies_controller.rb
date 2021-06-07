module Accounts
  module Apps
    module Incidents
      # Account app incident notification resending
      class NotifiesController < AuthenticatedController
        def update
          authorize incident, :notify?

          send_notifications!
          flash[:notice] = "Notifications for Incident ##{incident.id} has been resent"

          redirect_to account_apps_incident_path(account, incident)
        end

        private

        def send_notifications!
          incident.account.self_and_all_ancestors.each do |account|
            IncidentsMailer.notify(account, incident).deliver_later
          end
        end

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
