# :nodoc
module CiscoUmbrella
  # :nodoc
  module Services
    # :nodoc
    class PullOrganizations
      include ErrorHelper

      URL = "https://management.api.umbrella.com/v1/organizations".freeze

      def initialize(cred, params = {})
        @app_id = Apps::CiscoUmbrellaApp.first.id
        @cred   = cred.is_a?(Integer) ? Credentials::CiscoUmbrella.find(cred) : cred
        @params = params
        @query  = params.except(:url, :method)
        @url    = params[:url] || params["url"] || URL
        @method = "get"
        @wait   = 8.hours
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::CiscoUmbrella) || @url.nil? || @app_id.nil?
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        options = { url: @url, method: @method }.merge(@query)
        response = CiscoUmbrella::Services::Pull.new(@cred, options).call
        process(response)
      end

      private

      def process(response)
        org_ids = []
        response.each do |org|
          org_ids << org["organizationId"]
          ServiceRunnerJob.perform_later("CiscoUmbrella::Services::PullActivities",
                                         @cred, @app_id, org["organizationId"])
        end
        @cred.organizations = org_ids
        @cred.save

        schedule_next
        response
      end

      def schedule_next
        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("CiscoUmbrella::Services::PullOrganizations", @cred.id, @params)
      end
    end
  end
end
