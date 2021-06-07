module Analysis
  # Submit a file for analysis
  class FilesController < BaseController
    def create
      authorize current_account, :can_on_demand_analyze?

      @analysis = ::Analysis::File.create(
        account: current_account, user: current_user,
        upload_id: upload_id
      )

      ServiceRunnerJob.perform_later("Analysis::Lookup::File", @analysis) if @analysis.persisted?
    end

    private

    def upload_id
      params.require(:analysis_file).require(:upload_id)
    end
  end
end
