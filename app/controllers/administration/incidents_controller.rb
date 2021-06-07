module Administration
  # :nodoc
  class IncidentsController < BaseController
    include Pagy::Backend
    include TriageExportable
    include TriageScopeable

    helper_method :incidents, :start_date, :end_date, :status

    def index
      authorize :administration, :manage_incidents?

      @pagination, @incidents = paginate_incidents
    end

    def show
      authorize :administration, :manage_incidents?
    end

    def create
      authorize :administration, :manage_incidents?

      respond_to do |format|
        format.js do
          if params[:export]
            export_results!(true)
          else
            redirect_to administration_incidents_path(query_params), turbolinks: :advance
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
        class_type, nil, collection, opts
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

    def download_options
      if params[:export] == "JSON"
        json_attributes.merge({ filename: "incidents_results" })
      else
        generic_headers.merge({ filename: "incidents_results" })
      end
    end

    def incident_list_headers
      {
        attrs:         (
          %I[id title description remediation state published_at resolved_at created_at]
        ),
        header_values: %I[id title description remediation state published_at resolved_at created_at],
        filename:      "incidents"
      }
    end

    # rubocop:disable Metrics/MethodLength
    def incidents
      results = policy_scope(::Apps::Incident)
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
      results.order("state ASC, created_at DESC") if results
    end
    # rubocop:enable Metrics/MethodLength

    def paginate_incidents
      pagy incidents
    end

    def query_params
      {
        start_date: params[:start_date], end_date: params[:end_date], search: params[:search],
        app_id: params[:app_id], status: params[:status]
      }.reject { |_k, v| v.blank? }
    end
  end
end
