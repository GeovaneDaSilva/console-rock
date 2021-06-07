# :nodoc
module Passly
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include ErrorHelper

      def initialize(params)
        @params = params
        @cred = Credentials::Passly.find(params["credential_id"])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        set_global_variables
        request = HTTPI::Request.new
        request.url = url
        request.headers = { "Accept"       => "application/json",
                            "Content-Type" => "application/x-www-form-urlencoded" }
        request.body = { "grant_type"    => "client_credentials",
                         "client_secret" => @app_secret,
                         "client_id"     => @app_id }
        begin
          resp = HTTPI.get(request)
          { code: resp.code, error: resp.error? }
        rescue Errno::ECONNRESET
          raise Passly::ConnectionPeerResetError
        end
      end

      private

      def set_global_variables
        @tenant_id  = @cred&.tenant_id || @params["tenant_id"]
        @app_id     = @cred&.app_id || @params["app_id"]
        @app_secret = @cred&.app_secret || @params["app_secret"]
      end

      def url
        "https://#{@tenant_id}.my.passly.com/authorize/token"
      end
    end
  end
end
