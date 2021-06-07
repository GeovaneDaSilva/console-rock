# :nodoc
module Sophos
  # :nodoc
  module Services
    # :nodoc
    class Authenticate
      include ErrorHelper
      include PostApiCallProcessor

      SOPHOS_AUTH_ENDPOINT = "https://id.sophos.com/api/v2/oauth2/token".freeze

      def initialize(credential)
        @credential = credential
      end

      def call
        return unless @credential.instance_of?(Credentials::Sophos)
        return true unless @credential.expiration.blank? || token_expired?

        _code, data = make_api_call
        save(data)
      end

      def make_api_call
        headers = { "Content-Type" => "application/x-www-form-urlencoded" }
        body    = {
          client_id:     @credential.sophos_client_id,
          client_secret: @credential.sophos_client_secret,
          grant_type:    "client_credentials",
          scope:         "token"
        }

        request = HTTPI::Request.new
        request.url = SOPHOS_AUTH_ENDPOINT
        request.headers = headers
        request.body = body
        response = HTTPI.post(request)
        credential_is_working(response)
        return if html_error(__FILE__, response, @credential.account_id)

        [response.code, parse_json(response.raw_body)]
      rescue Errno::ECONNRESET
        raise Sophos::ConnectionPeerResetError
      end

      private

      def save(data)
        return false if data.blank?

        @credential.assign_attributes(
          access_token:  data["access_token"],
          refresh_token: data["refresh_token"],
          expiration:    DateTime.current + data["expires_in"].seconds
        )
        @credential.save
      end

      def token_expired?
        expiration = Time.zone.at(@credential.expiration - 5.minutes)
        Time.zone.now > expiration
      end

      def parse_json(text)
        JSON.parse(text)
      rescue JSON::ParserError
        text
      end
    end
  end
end
