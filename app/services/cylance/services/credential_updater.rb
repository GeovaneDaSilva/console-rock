# :nodoc
module Cylance
  # :nodoc
  module Services
    # :nodoc
    class CredentialUpdater
      include ErrorHelper
      include PostApiCallProcessor

      CYLANCE_AUTH_ENDPOINT = "https://protectapi.cylance.com".freeze

      def initialize(cred)
        @cred = cred
      end

      def call
        return unless @cred.is_a?(Credentials::Cylance)

        access_token
      end

      private

      def access_token
        if @cred.expiration.nil? || (@cred.expiration + 300) > Time.current
          new_access_token
        else
          @cred.access_token || new_access_token
        end
      end

      def new_access_token
        secret  = @cred.cylance_app_secret
        encoded = JWT.encode(claims, secret, "HS256")

        base_url = @cred.base_url || CYLANCE_AUTH_ENDPOINT
        url = "#{base_url}/auth/v2/token"

        request = HTTPI::Request.new
        request.url = url
        request.headers = { "Content-Type" => "application/json; charset=utf-8" }
        request.body = { "auth_token" => encoded }.to_json

        begin
          resp = HTTPI.post(request)
          credential_is_working(resp)
        rescue Errno::ECONNRESET
          raise Cylance::ConnectionPeerResetError
        end

        return if html_error(__FILE__, resp, @cred.customer_id.to_s)

        data = JSON.parse(resp.raw_body)
        save_token({ access_token: data["access_token"], expiration: 30.minutes.from_now })
        data["access_token"]
      end

      def claims
        timeout = 1800 # 30minutes
        now = Time.current.utc.to_i
        timeout_datetime = now + timeout
        {
          "exp" => timeout_datetime,
          "iat" => now,
          "iss" => "http://cylance.com",
          "sub" => @cred.cylance_app_id,
          "tid" => @cred.tenant_id,
          "jti" => SecureRandom.uuid
          # The following is optional and is being noted here as an example on how one can restrict
          # the list of scopes being requested
          # "scp": "policy:create, policy:list, policy:read, policy:update"
        }
      end

      def save_token(data)
        @cred.assign_attributes(data)
        @cred.save ? true : Rails.logger.error("Credential save fail for id #{@cred.id}")
      end
    end
  end
end
