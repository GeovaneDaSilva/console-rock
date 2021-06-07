# :nodoc
module Cylance
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include ErrorHelper
      include PostApiCallProcessor

      CYLANCE_AUTH_ENDPOINT = "https://protectapi.cylance.com".freeze

      def initialize(params)
        @tenant_id = params[:tenant_id]
        @app_id = params[:app_id]
        @app_secret = params[:app_secret]
        @cred = Credentials::Cylance.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        app_secret = @cred&.cylance_app_secret || @app_secret
        encoded = JWT.encode(claims, app_secret, "HS256")

        base_url = @cred&.base_url || CYLANCE_AUTH_ENDPOINT
        url = "#{base_url}/auth/v2/token"

        request = HTTPI::Request.new
        request.url = url
        request.headers = { "Content-Type" => "application/json; charset=utf-8" }
        request.body = { "auth_token" => encoded }.to_json

        begin
          resp = HTTPI.post(request)
          credential_is_working(resp)
          { code: resp.code, error: resp.error? }
        rescue Errno::ECONNRESET
          raise Cylance::ConnectionPeerResetError
        end
      end

      private

      def claims
        timeout = 1800 # 30minutes
        now = Time.current.utc.to_i
        timeout_datetime = now + timeout
        {
          "exp" => timeout_datetime,
          "iat" => now,
          "iss" => "http://cylance.com",
          "sub" => @cred&.cylance_app_id || @app_id,
          "tid" => @cred&.tenant_id || @tenant_id,
          "jti" => SecureRandom.uuid
        }
      end
    end
  end
end
