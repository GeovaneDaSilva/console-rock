module Office365s
  # Ability to export O365 User 2FA lists
  class ExportsController < AuthenticatedController
    def show
      authorize(current_account, :show?)

      respond_to do |format|
        format.js do
          @job_id = PolledTaskRunner.new.call(report_type, current_account, options)
                                    .key.split("/").last
          render partial: "shared/download_report"
        end
      end
    end

    private

    def options
      {
        attrs:         %I[external_id] + [{ details: %I[mfa_status] }],
        header_values: %I[userPrincipalName mfaEnabled],
        filename:      "#{current_account.name.parameterize}-user-2fa"
      }.to_json
    end

    def report_type
      "Reports::OfficeUsersMfa::CsvReporter"
    end
  end
end
