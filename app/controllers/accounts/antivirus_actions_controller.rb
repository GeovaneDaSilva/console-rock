module Accounts
  # Perform AV actions on behalf of customers
  class AntivirusActionsController < AuthenticatedController
    include Pagy::Backend

    helper_method :app_results

    def index
      authorize current_account, :perform_antivirus_actions?

      @av_vendor = ::App.find(params[:app_id])&.configuration_type
      @pagination, @app_results = pagy app_results
    end

    def update
      authorize current_account, :perform_antivirus_actions?

      params[:actions].each do |key, value|
        ServiceRunnerJob.perform_later(
          "#{params[:av_vendor].humanize}::Manage::#{key.camelcase}", [params[:id]], value
        )
      end
      flash[:notice] = "Jobs successfully enqueued"

      redirect_back fallback_location: root_url
    end

    def create
      authorize current_account, :perform_antivirus_actions?

      params[:actions].each do |key, value|
        ServiceRunnerJob.perform_later(
          "#{params[:av_vendor].humanize}::Manage::#{key.camelcase}", params[:app_results], value
        )
      end
      flash[:notice] = "Jobs successfully enqueued"

      redirect_back fallback_location: root_url
    end

    private

    def app_results
      @app_results ||= ::Apps::Result.where(id: params[:app_results])
    end
  end
end
