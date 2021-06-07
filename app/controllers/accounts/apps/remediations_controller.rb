module Accounts
  module Apps
    # Account app incidents
    class RemediationsController < AuthenticatedController
      include Pagy::Backend

      helper_method :account, :incidents, :incident, :remediations

      def show
        authorize incident, :remediate?

        @total_remediations = all_remediations&.size || 0
        @pagination, @remediations = paginate_remediations
      end

      private

      def incident
        @incident ||= incidents.find(params[:id])
      end

      def account
        @account ||= policy_scope(Account).find(params[:account_id])
      end

      def incidents
        policy_scope(account.all_descendant_incidents.order("state ASC, updated_at DESC"))
      end

      def incident_params
        params.require(:apps_incident).permit(:title, :description, :remediation)
      end

      def remediations
        if params[:status]
          all_remediations&.where(status: params[:status]) || []
        else
          all_remediations || []
        end
      end

      def all_remediations
        @all_remediations ||= incident.remediation_plan&.remediations
                                      &.joins("inner join devices on devices.id = remediations.target_id")
                                      &.select("devices.hostname as hostname, remediations.*")
                                      &.order("hostname")
      end

      def paginate_remediations
        pagy_array remediations, items: 25
      end
    end
  end
end
