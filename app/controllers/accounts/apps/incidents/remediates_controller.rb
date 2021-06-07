module Accounts
  module Apps
    module Incidents
      # Account app incidents
      class RemediatesController < AuthenticatedController
        helper_method :incident, :remediations, :account

        def show
          authorize incident, :remediate?
        end

        def update
          authorize incident, :remediate?

          isolate_all! if params[:isolate_all]
          # Commented out for future use: 2020-09-11
          # av_full_scan! if params[:av_full_scan]
          update_active

          unless incident.published?
            if incident.published!
              send_notifications!
              flash[:notice] = "Incident ##{incident.id} has been published"
            else
              flash[:error] = "Unable to publish incident ##{incident.id}"
            end
          end

          ServiceRunnerJob.perform_later("Incidents::ExecuteRemediationPlan", incident.remediation_plan.id)
          flash[:notice] = "Remediation has begun"

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

        def remediations
          return @remediations unless @remediations.nil?

          @remediations = incident.remediation_plan&.remediations&.where&.not(status: :complete)
                                    &.joins("inner join devices on devices.id = remediations.target_id")
                                    &.select("devices.hostname as hostname, remediations.*")
                                    &.order("hostname")
                                    &.page(params[:page])&.per(30)
          @remediations ||= []
        end

        def av_full_scan!
          add_to_payload("defender_full_scan", true)
        end

        def isolate_all!
          add_to_payload("isolate", true)
        end

        def add_to_payload(key, value)
          remediations.each do |remediation|
            actions = remediation.actions
            actions["payload"][key] = value
            remediation.update(actions: actions)
          end
        end

        def send_notifications!
          incident.account.self_and_all_ancestors.each do |account|
            IncidentsMailer.notify(account, incident).deliver_later
          end
        end

        def update_active
          remediations.where(id: params[:remediations]).update_all(active: true)
          remediations.where.not(id: params[:remediations]).update_all(active: false)
        end
      end
    end
  end
end
