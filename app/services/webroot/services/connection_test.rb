# :nodoc
module Webroot
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include PostApiCallProcessor

      def initialize(params)
        @params = params
        @cred = Credentials::Webroot.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        authenticate
      end

      def authenticate
        headers = { Authorization: "Basic #{basic_auth_string}" }
        body = {
          username:   @cred&.webroot_username || @params[:webroot_username],
          password:   @cred&.webroot_password || @params[:webroot_password],
          grant_type: "password",
          scope:      ENV["WEBROOT_SCOPES"]
        }
        request = HTTPI::Request.new
        request.url = "https://unityapi.webrootcloudav.com/auth/token"
        request.headers = headers
        request.body = body
        begin
          response = HTTPI.post(request)
          credential_is_working(response)
          { code:  response.code,
            error: (response.code != 200) }
        rescue Errno::ECONNRESET
          raise ConnectionPeerResetError
        end
      end

      private

      def basic_auth_string
        return @cred&.webroot_basic_auth_string if @cred&.webroot_basic_auth_string
        return @params[:webroot_basic_auth_string] if @params[:webroot_basic_auth_string]

        auth_string = "#{@params[:webroot_client_id]}:#{@params[:webroot_client_secret]}"
        Base64.encode64(auth_string).delete("\n")
      end
    end
  end
end
