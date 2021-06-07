# :nodoc
module CiscoUmbrella
  # :nodoc
  module Services
    # :nodoc
    class CredentialUpdater
      include ErrorHelper

      CISCO_AUTH_ENDPOINT = "https://management.api.umbrella.com/auth/v2/oauth2/token".freeze

      def initialize(cred)
        @cred = cred
      end

      def call
        return unless @cred.is_a?(Credentials::CiscoUmbrella)

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
        token = @cred.base64
        request = HTTPI::Request.new
        request.url = CISCO_AUTH_ENDPOINT
        request.headers = { "Content-Type"  => "application/json",
                            "Authorization" => "Basic #{token}" }
        request.body = { "grant_type" => "client_credentials",
                         "user"       => token }.to_json

        begin
          resp = HTTPI.post(request)
        rescue Errno::ECONNRESET
          raise CiscoUmbrella::ConnectionPeerResetError
        end

        return if html_error(__FILE__, resp, @cred.customer_id.to_s)

        data = JSON.parse(resp.raw_body)
        save_token({ access_token: data["access_token"],
                     expiration:   Time.current + data["expires_in"].to_i })
        data["access_token"]
      end

      def save_token(data)
        @cred.assign_attributes(data)
        @cred.save ? true : Rails.logger.error("Credential save fail for id #{@cred.id}")
      end
    end
  end
end
