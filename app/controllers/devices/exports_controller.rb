module Devices
  # Ability to export device lists
  class ExportsController < AuthenticatedController
    def show
      authorize(current_account, :show?)

      respond_to do |format|
        format.js do
          @job_id = PolledTaskRunner.new.call(report_type, current_account, download_opts)
                                    .key.split("/").last
          render partial: "shared/download_report"
        end
      end
    end

    private

    def device
      @device ||= current_account.all_descendant_devices
                                 .find(params[:device_id].downcase)
    end

    def download_opts
      params[:firewall].present? ? firewalls_download_opts : devices_download_opts
    end

    def devices_download_opts
      {
        attrs:         (
          %I[id hostname ipv4_address mac_address network os] + [%I[customer name]] +
          %I[last_connected_at]
        ),
        header_values: %I[fingerprint hostname ip mac network os customer_name last_connected],
        filename:      "#{current_account.name.parameterize}-all-devices",
        filters:       params.permit!.except(:action, :controller)
      }.to_json
    end

    def firewalls_download_opts
      {
        attrs:         ([{ details: [%I[details device_id], %I[device_id]] },
                         { details: [%I[details ip], %I[ip]] },
                         { details: [%I[details type], %I[type]] },
                         { details: [%I[details mac], %I[mac]] }] + [%I[account name]]),
        header_values: %I[device_id ip type mac customer],
        filename:      "#{current_account.name.parameterize}-all-firewalls",
        filters:       params.permit!.except(:action, :controller)
      }.to_json
    end

    def report_type
      params[:firewall].present? ? firewalls_report_type : devices_report_type
    end

    def firewalls_report_type
      case params[:type]
      when "csv"
        "Reports::Firewalls::CsvReporter"
        # when "xlsx"
        #   "Reports::Firewalls::XlsxReporter"
      end
    end

    def devices_report_type
      case params[:type]
      when "csv"
        "Reports::Devices::CsvReporter"
        # when "xlsx"
        #   "Reports::Devices::XlsxReporter"
      end
    end
  end
end
