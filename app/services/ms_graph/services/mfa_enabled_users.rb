module MsGraph
  module Services
    # :nodoc
    class MfaEnabledUsers
      include ErrorHelper
      URL = "https://graph.microsoft.com/beta/reports/credentialUserRegistrationDetails".freeze

      def initialize(credential_id)
        @cred = Credential.find_by(id: credential_id)
      end

      def call
        return if @cred.nil?
        return unless @cred.customer.customer?
        return if @cred.customer.billing_account.actionable_past_due?

        token = ::MsGraph::CredentialUpdater.new.call(@cred)
        resp = make_api_call(token)
        return if html_error(__FILE__, resp)

        process(resp)
      end

      private

      def make_api_call(token)
        request = HTTPI::Request.new
        request.url = URL
        request.headers = { Authorization: "Bearer #{token}" }

        HTTPI.get(request)
      end

      def process(resp)
        temp = JSON.parse(resp.raw_body)
        # As of initial release, endpoint didn't do pagination
        return if temp.dig("value").blank?

        ServiceRunnerJob.set(queue: :utility).perform_later(
          "MsGraph::SaveTemplates::UserMfa", @cred.customer, temp.dig("value")
        )
      end
    end
  end
end
