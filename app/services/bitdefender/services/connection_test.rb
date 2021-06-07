# :nodoc
module Bitdefender
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include PostApiCallProcessor

      URL = "https://cloud.gravityzone.bitdefender.com/api/v1.0/jsonrpc/general".freeze
      def initialize(params)
        @access_token = params[:access_token]
        @cred = Credentials::Bitdefender.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        token = @cred ? @cred.access_token : @access_token
        headers = {
          "Content-Type"  => "application/json",
          "Authorization" => "Basic #{Base64.encode64("#{token}:").delete("\n")}"
        }
        request = HTTPI::Request.new
        request.url = URL
        request.headers = headers
        request.body = {
          "id": SecureRandom.uuid, "jsonrpc": "2.0",
          "method": "getApiKeyDetails", "params": []
        }.to_json

        begin
          result = HTTPI.post(request)
          credential_is_working(result)
          { code:  result.code,
            error: (result.code != 200) }
        rescue Errno::ECONNRESET
          raise Bitdefender::ConnectionPeerResetError
        end
      end
    end
  end
end
