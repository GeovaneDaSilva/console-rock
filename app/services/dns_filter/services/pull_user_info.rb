# :nodoc
module DnsFilter
  # :nodoc
  module Services
    # :nodoc
    class PullUserInfo
      include PostApiCallProcessor
      URL = "https://api.dnsfilter.com/v1/authenticate".freeze

      DEFAULT_WAIT = 24.hours.freeze

      def initialize(credential, options = {})
        @credential = credential
        @options    = options
      end

      def call
        return if @credential.nil? || !@credential.instance_of?(Credentials::DnsFilter)
        return if @credential.account.billing_account.paid_thru < DateTime.current

        authenticate

        data = make_api_call
        persist(data)
        schedule_next
      end

      private

      def authenticate
        DnsFilter::Services::Authenticate.new(@credential).call
      end

      def make_api_call
        headers = { Authorization: "Bearer #{@credential.access_token}" }

        request = HTTPI::Request.new
        request.url = URL
        request.headers = headers
        response = HTTPI.post(request)
        credential_is_working(response)

        body = parse_json(response.raw_body)

        unless response.code == 200
          Rails.logger.error("DNSFilter pull user info error. Code #{response.code} with message #{body}")
          return
        end

        body
      rescue Errno::ECONNRESET
        raise DnsFilter::ConnectionPeerResetError
      end

      def persist(data)
        DnsFilter::SaveTemplates::UserInfo.new(@credential, data).call
      end

      def schedule_next
        wait = @options.fetch(:wait, DEFAULT_WAIT)
        ServiceRunnerJob
          .set(wait: wait, queue: :utility)
          .perform_later("DnsFilter::Services::PullUserInfo", @credential)
      end

      def parse_json(text)
        JSON.parse(text)
      rescue JSON::ParserError
        text
      end
    end
  end
end
