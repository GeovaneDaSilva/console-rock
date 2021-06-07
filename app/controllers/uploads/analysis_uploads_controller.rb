module Uploads
  # Uploads associated with a analysis
  class AnalysisUploadsController < AuthenticatedController
    include Uploadable

    private

    def create_upload!
      authorize current_account, :can_on_demand_analyze?

      @upload = current_account.uploads.create(upload_params)
    end

    def upload_url
      uploads_analysis_upload_url(@upload, host: ENV.fetch(I18n.t("application.host"), ENV["HOST"]))
    end

    def filesize
      0..15.megabytes
    end
  end
end
