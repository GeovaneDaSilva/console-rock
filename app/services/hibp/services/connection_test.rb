# :nodoc
module Hibp
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include PostApiCallProcessor

      def initialize(params)
        @access_token = params[:access_token]
        @cred = Credentials::Hibp.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        request = HTTPI::Request.new
        request.url = "https://haveibeenpwned.com/api/v3/pasteaccount/test@example.com".freeze
        request.headers = { "hibp-api-key" => @cred&.hibp_api_key || @access_token }

        begin
          result = HTTPI.get(request)
          credential_is_working(result)
          { code:  result.code,
            error: (result.code != 200) }
        rescue Errno::ECONNRESET
          raise Hibp::ConnectionPeerResetError
        end
      end
    end
  end
end
