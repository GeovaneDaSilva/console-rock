# :nodoc
module Passly
  # :nodoc
  module Services
    # :nodoc
    class CredentialUpdater
      include ErrorHelper

      def initialize(cred)
        @cred = cred
      end

      def call
        return unless @cred.is_a?(Credentials::Passly)

        access_token
      end

      private

      def url
        "https://#{@cred.tenant_id}.my.passly.com/authorize/token"
      end

      def access_token
        if @cred.expiration.nil? || @cred.expiration < (Time.current + 300)
          new_access_token
        else
          @cred.access_token || new_access_token
        end
      end

      def new_access_token
        request = HTTPI::Request.new
        request.url = url
        request.headers = { "Accept"       => "application/json",
                            "Content-Type" => "application/x-www-form-urlencoded" }
        request.body = { "grant_type"    => "client_credentials",
                         "client_secret" => @cred.app_secret,
                         "client_id"     => @cred.app_id }
        begin
          resp = HTTPI.post(request)
          { code: resp.code, error: resp.error? }
        rescue Errno::ECONNRESET
          raise Passly::ConnectionPeerResetError
        end

        return if html_error(__FILE__, resp, @cred.customer_id.to_s)

        data = JSON.parse(resp.raw_body)
        save_token({ access_token: data["access_token"],
                     expiration:   Time.zone.at(data["exp"].to_i) })
        data["access_token"]
      end

      def save_token(data)
        @cred.assign_attributes(data)
        @cred.save ? true : Rails.logger.error("Credential save fail for id #{@cred.id}")
      end
    end
  end
end
