# :nodoc
module Ironscales
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include ErrorHelper
      include PostApiCallProcessor

      IRONSCALES_TOKEN_ENDPOINT = "https://appapi.ironscales.com:443/appapi/get-token/".freeze

      def initialize(params)
        @refresh_token = params[:refresh_token]
        @cred = Credentials::Ironscales.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        request = HTTPI::Request.new
        request.url = IRONSCALES_TOKEN_ENDPOINT
        request.headers = { "Content-Type" => "application/json" }
        request.body = { "key"    => @cred&.refresh_token || @refresh_token,
                         "scopes" => ["partner.all"] }.to_json
        begin
          result = HTTPI.post(request)
          credential_is_working(result)
          { code:  result.code,
            error: (result.code != 200) }
        rescue Errno::ECONNRESET
          raise Ironscales::ConnectionPeerResetError
        end
      end
    end
  end
end
