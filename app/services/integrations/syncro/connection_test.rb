module Integrations
  module Syncro
    # Ping an API endpoint
    class ConnectionTest
      include HttpHelper
      include PostApiCallProcessor

      def initialize(params)
        @params = params[:credentials_syncro] || params
        @cred = Credentials::Syncro.find(@params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        response = make_api_call(build_url, build_headers, {}, {}, "get")
        credential_is_working(response)
        { code: response.code, error: (response.code != 200) }
      rescue SocketError, URI::BadURIError, URI::InvalidURIError
        { code: "(Invalid credentials)", error: true }
      end

      private

      def build_url
        subdomain = @cred&.base_url || @params[:subdomain] || @params[:base_url]
        valid_url(subdomain)
        "#{subdomain}/api/v1/search"
      end

      def build_headers
        api_key = @cred&.syncro_api_key || @params[:api_key] || @params[:syncro_api_key]
        { Authorization: "Bearer #{api_key}" }
      end

      def valid_url(url)
        uri = URI.parse(url)
        %w[http https].include?(uri.scheme)
      end
    end
  end
end
