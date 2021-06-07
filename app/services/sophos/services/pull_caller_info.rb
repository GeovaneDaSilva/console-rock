# :nodoc
module Sophos
  # :nodoc
  module Services
    # :nodoc
    class PullCallerInfo
      include PostApiCallProcessor

      URL = "https://api.central.sophos.com/whoami/v1".freeze

      DEFAULT_WAIT = 24.hours.freeze

      def initialize(credential, options = {})
        @credential = credential
        @options    = options
      end

      def call
        return if @credential.nil? || !@credential.instance_of?(Credentials::Sophos)

        authenticate

        data = make_api_call
        persist(data)

        schedule_next
      end

      private

      def authenticate
        Sophos::Services::Authenticate.new(@credential).call
      end

      def make_api_call
        headers = { Authorization: "Bearer #{@credential.access_token}" }

        request = HTTPI::Request.new
        request.url = URL
        request.headers = headers
        response = HTTPI.get(request)
        credential_is_working(response)

        body = parse_json(response.raw_body)

        unless response.code == 200
          Rails.logger.error("Sophos pull caller info error. Code #{response.code} with message #{body}")
          return
        end

        body
      rescue Errno::ECONNRESET
        raise Sophos::ConnectionPeerResetError
      end

      def persist(data)
        Sophos::SaveTemplates::CallerInfo.new(@credential, data).call
      end

      def schedule_next
        wait = @options.fetch(:wait, DEFAULT_WAIT)
        ServiceRunnerJob
          .set(wait: wait, queue: :utility)
          .perform_later("Sophos::Services::PullCallerInfo", @credential)
      end

      def parse_json(text)
        JSON.parse(text)
      rescue JSON::ParserError
        text
      end
    end
  end
end
