module Integrations
  module Connectwise
    # Ping an API endpoint
    class ConnectionTest
      include PostApiCallProcessor

      API_REV  = "/v4_6_release/apis/3.0".freeze
      ENDPOINT = "/company/companies/types".freeze

      def initialize(params)
        @params = params[:credentials_connectwise] || params
        @cred = Credentials::Connectwise.find(@params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        response = make_api_call
        credential_is_working(response)
        { code: response.code, error: (response.code != 200) }
      end

      private

      def public_api_key
        @public_api_key ||= @cred&.connectwise_psa_public_api_key || \
                            @params[:public_api_key] || \
                            @params[:connectwise_psa_public_api_key]
      end

      def private_api_key
        @private_api_key ||= @cred&.connectwise_psa_private_api_key || \
                             @params[:private_api_key] || \
                             @params[:connectwise_psa_private_api_key]
      end

      def company_id
        @company_id ||= @cred&.connectwise_company_id || \
                        @params[:company_id] || \
                        @params[:connectwise_company_id]
      end

      def auth_string
        string = "#{company_id}+#{public_api_key}:#{private_api_key}"
        Base64.encode64(string).delete("\n")
      end

      def headers
        {
          clientId:      ENV["CONNECTWISE_API_CLIENT_ID"],
          Authorization: "Basic #{auth_string}"
        }
      end

      def base_url
        "#{@cred&.base_url || @params[:base_url]}#{API_REV}"
      end

      def make_api_call
        url   = "#{base_url}#{ENDPOINT}"
        query = { "pagesize" => 1 }

        request = HTTPI::Request.new
        request.headers = headers
        request.url = url
        request.query = query
        HTTPI.get(request)
      rescue ArgumentError
        OpenStruct.new(code: "Invalid details")
      rescue Errno::ECONNRESET
        raise Connectwise::ConnectionPeerResetError
      end
    end
  end
end
