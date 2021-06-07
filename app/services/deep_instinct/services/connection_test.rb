# :nodoc
module DeepInstinct
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include ErrorHelper
      include PostApiCallProcessor

      URL = "https://partner1.poc.deepinstinctweb.com".freeze

      def initialize(params)
        @access_token = params[:access_token]
        @url = params[:base_url] || URL
        @cred = Credentials::Webroot.find_by(id: params[:credential_id])
      end

      def call
        headers = {
          "Content-Type"  => "application/json",
          "Authorization" => @cred ? @cred.access_token : @access_token
        }
        request = HTTPI::Request.new
        request.url = "#{@url}/api/v1/groups/"
        request.headers = headers
        request.query = {}
        request.body = {}.to_json

        begin
          result = HTTPI.get(request)
          credential_is_working(result)
          { code:  result.code,
            error: (result.code != 200) }
        rescue Errno::ECONNRESET
          raise DeepInstinct::ConnectionPeerResetError
        end
      end
    end
  end
end
