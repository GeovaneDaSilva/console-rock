module DnsFilter
  # :nodoc
  module Services
    # :nodoc
    class Authenticate
      include ErrorHelper
      include PostApiCallProcessor

      DNS_FILTER_AUTH_ENDPOINT = "https://dnsfilter.auth0.com/oauth/token".freeze

      def initialize(credential)
        @credential = credential
      end

      def call
        return unless @credential.instance_of?(Credentials::DnsFilter)
        return true unless @credential.expiration.blank? || token_expired?

        code, data = make_api_call
        save(code, data)
      end

      def make_api_call
        body = build_request_body

        request = HTTPI::Request.new
        request.url = DNS_FILTER_AUTH_ENDPOINT
        request.body = body
        response = HTTPI.post(request)
        credential_is_working(response)

        html_error(__FILE__, response, @credential.account_id)

        [response.code, parse_json(response.raw_body)]
      rescue Errno::ECONNRESET
        raise DnsFilter::ConnectionPeerResetError
      end

      private

      def save(code, data)
        return false, data if code != 200

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

      def build_request_body
        if @credential.expiration && token_expired?
          {
            grant_type:    "refresh_token",
            client_id:     "zJ1WJHavuUFx89cConwlipxoOc2J3TVQ",
            refresh_token: @credential.refresh_token,
            scope:         "enroll read:authenticators remove:authenticators offline_access openid " \
                           "picture name email"
          }
        else
          {
            realm:      "Username-Password-Authentication",
            grant_type: "http://auth0.com/oauth/grant-type/password-realm",
            audience:   "https://dnsfilter.auth0.com/mfa/",
            username:   @credential.dns_filter_username,
            password:   @credential.dns_filter_password,
            client_id:  "zJ1WJHavuUFx89cConwlipxoOc2J3TVQ",
            scope:      "enroll read:authenticators remove:authenticators offline_access openid " \
                        "picture name email"
          }
        end
      end

      def parse_json(text)
        JSON.parse(text)
      rescue JSON::ParserError
        text
      end
    end
  end
end
