# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class PullDomains
      include ErrorHelper

      BASE_URL = "https://graph.microsoft.com/v1.0/domains".freeze

      def initialize(credential)
        @cred = credential
      end

      def call
        return if @cred.nil?

        pull_domains
      end

      private

      def make_api_call(token)
        request = HTTPI::Request.new
        request.url = BASE_URL
        request.headers = { Authorization: "Bearer #{token}" }

        HTTPI.get(request)
      end

      def pull_domains
        token = ::MsGraph::CredentialUpdater.new.call(@cred)
        resp = make_api_call(token)
        return if html_error(__FILE__, resp)

        process(resp)
      end

      def process(resp)
        temp = JSON.parse(resp.raw_body)
        domains = temp.dig("value").map { |n| n.dig("id") }.compact
        @cred.update(ms_base_domains: domains)

        domains
      end
    end
  end
end
