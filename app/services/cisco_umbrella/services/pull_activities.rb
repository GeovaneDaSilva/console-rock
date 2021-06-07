# :nodoc
module CiscoUmbrella
  # :nodoc
  module Services
    # :nodoc
    class PullActivities
      include ErrorHelper

      def initialize(cred, app_id, organization_id, params = {})
        @app_id = app_id || Apps::CiscoUmbrellaApp.first.id
        @organization_id = organization_id
        @cred = cred.is_a?(Integer) ? Credentials::CiscoUmbrella.find(cred) : cred
        @params = params
        @query = params.except(:url, :method)
        @url = params[:url] || params["url"] || URL
        @method = "get"
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::CiscoUmbrella) || @url.nil? \
          || @organization_id.nil?
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        response = CiscoUmbrella::Services::Pull.new(@cred, options).call
        process(response)
      end

      private

      def options
        {
          url:    url,
          method: @method,
          from:   9.hours.ago.to_i,
          to:     Time.current.to_i
        }.merge(@query)
      end

      def url
        "https://reports.api.umbrella.com/v2/organizations/#{@organization_id}/activity"
      end

      def process(response)
        response.each do |activity|
          ServiceRunnerJob.perform_later("CiscoUmbrella::SaveTemplates::Activity",
                                         @cred, activity, @app_id)
        end
        response
      end
    end
  end
end
