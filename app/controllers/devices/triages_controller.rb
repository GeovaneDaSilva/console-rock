module Devices
  # :nodoc
  class TriagesController < AuthenticatedController
    include Triagable

    helper_method :device, :account

    def show
      authorize device, :triage?

      @pagination, @similar_detections = paginate_similar_detections

      if app_results.none?
        flash[:notice] = "No results to review for this device"
        redirect_to fallback_location
      end
    end

    def create
      authorize device, :triage?

      respond_to do |format|
        format.js do
          if params[:delete]
            delete_results!
          elsif params[:whitelist]
            whitelist_results!
          elsif params[:incident]
            incident_results!
          elsif params[:logic_rule]
            logic_rule_results!
          elsif params[:export]
            export_results!
          else
            redirect_to triage_path(query_params), turbolinks: :advance
          end
        end
      end
    end

    private

    def delete_results!
      @job_id = PolledTaskRunner.new.call(
        "Apps::Results::Destroyer", app, device, params.permit!
      ).key.split("/").last

      @result_path = triage_path(query_params)
      render "triages/create"
    end

    def whitelist_results!
      redirect_to device_triage_whitelist_path(
        device, query_params.merge(app_results: params[:app_results])
      ), turbolinks: :advance
    end

    def incident_results!
      redirect_to device_triage_incident_path(
        device, query_params.merge(
                  app_results: params[:app_results], apply_to_all_similar: params[:apply_to_all_similar]
                )
      ), turbolinks: :advance
    end

    def logic_rule_results!
      redirect_to device_triage_logic_rule_path(
        device, query_params.merge(account_id: account.id, app_results: params[:app_results])
      ), turbolinks: :advance
    end

    def export_results!
      @job_id = PolledTaskRunner.new.call(
        report_type, device, download_options
      ).key.split("/").last
      render partial: "shared/download_report"
    end

    def report_type
      case export_type
      when "csv"
        "Reports::Devices::Triage::CsvReporter"
      # when "xlsx"
      #   "Reports::Devices::Triage::XlsxReporter"
      when "json"
        "Reports::Devices::Triage::JsonReporter"
      end
    end

    def account
      device.customer
    end

    def app_results
      device.app_results.includes(:customer).where(incident_id: nil)
    end

    def app_counter_caches
      device.app_counter_caches.where(app: app)
    end

    def device
      @device ||= Device.find(params[:device_id])
    end

    def triage_path(*opts)
      device_triage_path(device, *opts)
    end

    def fallback_location
      device_path(device)
    end
  end
end
