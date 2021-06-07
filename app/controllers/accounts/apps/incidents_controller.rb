module Accounts
  module Apps
    # Account app incidents
    class IncidentsController < AuthenticatedController
      include Pagy::Backend
      include TriageExportable
      include TriageScopeable

      helper_method :account, :incidents, :incident, :ui_limit_exceeded?, :paged_remediations,
                    :remediations, :start_date, :end_date, :triage_path, :status

      def index
        authorize account, :manage_incidents?

        @pagination, @incidents = pagy incidents
      end

      def create
        authorize account, :triage?
        respond_to do |format|
          format.html do
            if params[:whitelist]
              whitelist
            elsif params[:antivirus_actions]
              redirect_to account_antivirus_actions_path(params.permit!.except(:page)), turbolinks: :advance
            else
              redirect_to account_apps_incidents_path(query_params), turbolinks: :advance
            end
          end

          format.js do
            if params[:export]
              export_results!(true)
            else
              redirect_to account_apps_incidents_path(query_params), turbolinks: :advance
            end
          end
        end
      end

      def whitelist
        authorize account, :manage_incidents?
        opts = {
          app_id:      params[:app_id] || app_results.first&.app_id,
          app_results: params[:app_results] || incident.results.pluck(:id),
          incident_id: params[:incident_id]
        }
        redirect_to account_triage_whitelist_path(account, opts)
      end

      def show
        authorize account, :manage_incidents?

        @total_remediations = remediations&.size || 0
        @pagination, @app_results = paginate_app_results
      end

      def edit
        authorize incident
      end

      def update
        authorize incident

        if incident.update(incident_params)
          ::Incidents::Integrations.update_ticket(incident, incident_params, account)
          flash[:notice] = "Incident ##{incident.id} updated"
          redirect_to account_apps_incident_path(account, incident)
        else
          flash.now[:error] = "Unable to update incident"
          render :edit
        end
      end

      def destroy
        authorize incident

        result_ids = incident.results.pluck(:id)

        if incident.destroy
          ServiceRunnerJob.perform_later("Apps::Results::UpdateCounterCaches", "increment", result_ids)
          ::Incidents::Integrations.destroy_ticket(incident)
          flash[:notice] = "Incident ##{incident.id} deleted"
        else
          flash[:error] = "Problem deleting incident"
        end

        redirect_to account_apps_incidents_path(account)
      end

      def export
        authorize account, :triage?

        respond_to do |format|
          format.js do
            if params[:export]
              export_results!
            else
              redirect_to account_apps_incident_path(account, incident), turbolinks: :advance
            end
          end
        end
      end

      private

      def export_results!(incident_list = false)
        if incident_list
          opts = incident_list_headers.to_json
          collection = incidents.to_a
        else
          opts = download_options.to_json
          collection = incident
        end

        @job_id = PolledTaskRunner.new.call(
          class_type, account, collection, opts
        ).key.split("/").last
        render partial: "shared/download_report"
      end

      def class_type
        case params[:export]
        when "JSON"
          "Reports::Incidents::JsonReporter"
        when "CSV"
          "Reports::Incidents::CsvReporter"
          # when "XLSX"
          #   "Reports::Incidents::XlsxReporter"
        end
      end

      def filename
        [account.name.parameterize, incident&.title&.parameterize, "results"].compact.join("-")
      end

      def download_options
        if params[:export] == "JSON"
          json_attributes.merge({ filename: filename })
        else
          generic_headers.merge({ filename: filename })
        end
      end

      def incident_list_headers
        {
          attrs:         (
            %I[id title description remediation state published_at resolved_at created_at]
          ),
          header_values: %I[id title description remediation state published_at resolved_at created_at],
          filename:      [account.name.parameterize, "incidents"].compact.join("-")
        }
      end

      def incident
        @incident ||= incidents.find(params[:id] || params[:incident_id])
      end

      def account
        @account ||= policy_scope(Account).find(params[:account_id])
      end

      # rubocop:disable Metrics/MethodLength
      def incidents
        results = policy_scope(account.all_descendant_incidents)
        if params["search"].present?
          id = begin
                 Integer(params["search"])
               rescue ArgumentError
                 nil
               end

          # rubocop:disable Style/ConditionalAssignment
          if id
            # rubocop:enable Style/ConditionalAssignment
            results = policy_scope(results.where(apps_incidents: { id: id }))
          else
            results = policy_scope(
              results.joins("INNER JOIN accounts a ON a.path=apps_incidents.account_path")
                     .where(["apps_incidents.title LIKE ? OR a.name LIKE ?",
                             "%#{params['search']}%",
                             "%#{params['search']}%"])
            )
          end
        end

        if params["start_date"].present? || params["end_date"].present?
          results = policy_scope(
            results.where(["apps_incidents.created_at BETWEEN ? AND ?",
                           Time.zone.strptime(params["start_date"], "%m/%d/%Y"),
                           Time.zone.strptime(params["end_date"], "%m/%d/%Y")])
          )
        end

        if params["status"].present?
          results = policy_scope(
            results.where(apps_incidents: { state: params["status"] })
          )
        end
        results.order("state ASC, updated_at DESC") if results
      end
      # rubocop:enable Metrics/MethodLength

      def ui_limit_exceeded?
        false
      end

      def incident_params
        params.require(:apps_incident).permit(:title, :description, :remediation)
      end

      # def paged_remediations
      #   remediation.page(params[:page])
      # end

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

      def triage_path(*opts)
        account_apps_incidents_path(account, *opts)
      end

      def app_results
        incident.results
      end

      def paginate_app_results
        pagy app_results, items: 10
      end

      def query_params
        {
          start_date: params[:start_date], end_date: params[:end_date], search: params[:search],
          app_id: params[:app_id], status: params[:status]
        }.reject { |_k, v| v.blank? }
      end

      def status
        params[:status]
      end
    end
  end
end
