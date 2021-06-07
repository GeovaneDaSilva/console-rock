# :nodoc
module Sentinelone
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include PostApiCallProcessor

      URL = "https://usea1-pax8.sentinelone.net".freeze

      # should probably use this url but it does not work. `my-user` returns large data
      # URL = "https://usea1-pax8.sentinelone.net/web/api/v2.0/users/api-token-details".freeze
      def initialize(params)
        @api_token = params[:api_token]
        @cred = Credentials::Sentinelone.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        api_token = @cred&.access_token || @api_token
        headers = {
          Authorization: "ApiToken #{api_token}"
        }
        request = HTTPI::Request.new
        request.url = "#{@cred&.sentinelone_url || URL}/web/api/v2.0/private/my-user"
        request.headers = headers

        begin
          result = HTTPI.get(request)
          credential_is_working(result)
          { code:  result.code,
            error: (result.code != 200) }
        rescue Errno::ECONNRESET
          raise SentinelOne::ConnectionPeerResetError
        end
      end
    end
  end
end
