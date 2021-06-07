# :nodoc
module Ironscales
  # :nodoc
  module Services
    # :nodoc
    class CredentialUpdater
      include ErrorHelper
      include PostApiCallProcessor

      IRONSCALES_TOKEN_ENDPOINT = "https://appapi.ironscales.com:443/appapi/get-token/".freeze

      def initialize(cred)
        @cred = cred
      end

      def call
        return unless @cred.is_a?(Credentials::Ironscales)

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
        request = HTTPI::Request.new
        request.url = IRONSCALES_TOKEN_ENDPOINT
        request.headers = { "Content-Type" => "application/json" }
        request.body = { "key"    => @cred.refresh_token,
                         "scopes" => ["partner.all"] }.to_json

        begin
          resp = HTTPI.post(request)
          credential_is_working(resp)
        rescue Errno::ECONNRESET
          raise Ironscales::ConnectionPeerResetError
        end

        return if html_error(__FILE__, resp, @cred.customer_id.to_s)

        data = JSON.parse(resp.raw_body)
        save_token({ access_token: data["jwt"], expiration: Time.current + 3600 })
        data["jwt"]
      end

      def save_token(data)
        @cred.assign_attributes(data)
        @cred.save ? true : Rails.logger.error("Credential save fail for id #{@cred.id}")
      end
    end
  end
end
