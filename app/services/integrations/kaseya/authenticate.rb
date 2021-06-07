module Integrations
  module Kaseya
    # :nodoc
    class Authenticate
      include HttpHelper
      include ErrorHelper
      include PostApiCallProcessor

      ENDPOINT = "/api/token".freeze

      def initialize(credential)
        @credential = credential
      end

      def call
        return unless @credential.instance_of?(Credentials::Kaseya)
        return unless @credential.expiration.blank? || token_expired?

        _code, data = generate_token
        save(data)
      end

      def generate_token
        response = make_api_call(build_url, build_headers, {}, build_request_body, "post")
        credential_is_working(response)
        [response.code, parse_json(response.raw_body)]
      rescue Errno::ECONNRESET
        raise Kaseya::ConnectionPeerResetError
      end

      private

      def build_url
        @credential.base_url + ENDPOINT
      end

      def build_headers
        {
          "content-type" => "application/x-www-form-urlencoded",
          "accept"       => "application/json"
        }
      end

      def build_request_body
        {
          grant_type: "password",
          username:   @credential.kaseya_username,
          password:   @credential.kaseya_password,
          tenant:     @credential.kaseya_tenant
        }
      end

      def save(data)
        @credential.assign_attributes(
          access_token: data["access_token"],
          token_type:   data["token_type"],
          expiration:   DateTime.current + data["expires_in"].seconds
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
