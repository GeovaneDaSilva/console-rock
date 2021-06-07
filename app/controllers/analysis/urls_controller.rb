module Analysis
  # Submit a url for analysis
  class UrlsController < BaseController
    def create
      authorize current_account, :can_on_demand_analyze?

      @analysis = ::Analysis::Url.create(
        account: current_account, user: current_user,
        url: url
      )

      ServiceRunnerJob.perform_later("Analysis::Lookup::Url", @analysis) if @analysis.persisted?
    end

    private

    def url
      params.require(:analysis_url).require(:url)
    end
  end
end
