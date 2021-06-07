# :nodoc
module Webroot
  # :nodoc
  module Services
    # :nodoc
    class CredentialUpdater
      include ErrorHelper
      include PostApiCallProcessor

      WEBROOT_AUTH_ENDPOINT = "https://unityapi.webrootcloudav.com/auth/token".freeze

      def initialize(cred)
        @cred = cred
      end

      def call
        return unless @cred.is_a?(Credential)

        refresh_tokens
      end

      private

      # rubocop: disable Metrics/MethodLength
      def refresh_tokens
        request = HTTPI::Request.new
        request.url = WEBROOT_AUTH_ENDPOINT
        request.headers = { Authorization: "Basic #{@cred.webroot_basic_auth_string}" }
        request.body = {
          refresh_token: @cred.refresh_token,
          grant_type:    "refresh_token",
          scope:         ENV["WEBROOT_SCOPES"]
        }

        begin
          resp = HTTPI.post(request)
          credential_is_working(resp)
        rescue Errno::ECONNRESET
          raise Webroot::ConnectionPeerResetError
        end

        if html_error(__FILE__, resp, @cred.customer_id.to_s)
          authenticate
        else
          data = JSON.parse(resp.raw_body)
          save_token(data)
          data["access_token"]
        end
      end
      # rubocop: enable Metrics/MethodLength

      def authenticate
        headers = { Authorization: "Basic #{@cred.webroot_basic_auth_string}" }
        body = {
          username:   @cred.webroot_username,
          password:   @cred.webroot_password,
          grant_type: "password",
          scope:      ENV["WEBROOT_SCOPES"]
        }

        request = HTTPI::Request.new
        request.url = WEBROOT_AUTH_ENDPOINT
        request.headers = headers
        request.body = body
        resp = HTTPI.post(request)
        credential_is_working(resp)
        return false if html_error(__FILE__, resp, @cred.customer_id.to_s)

        data = JSON.parse(resp.raw_body)
        save_token(data)
        data["access_token"]
      end

      def save_token(data)
        Rails.logger.error("No refresh token for id #{@cred.id}") if data["refresh_token"].nil?

        @cred.assign_attributes(refresh_token: data["refresh_token"])

        @cred.save ? true : Rails.logger.error("Credential save fail for id #{@cred.id}")
      end
    end
  end
end
