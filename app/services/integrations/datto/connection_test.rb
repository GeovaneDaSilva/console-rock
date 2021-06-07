module Integrations
  module Datto
    # Ping an API endpoint
    class ConnectionTest
      ENDPOINT = "v1.0/Tickets/entityInformation".freeze

      def initialize(params)
        @params = params[:credentials_datto] || params
        @cred = Credentials::Datto.find(@params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        code, metadata = zone_request
        return { code: code, error: (code != 200) } unless metadata

        response = make_api_call(metadata["url"])
        { code: response.code, error: (response.code != 200) }
      end

      private

      def credential_is_working(response, base_url = nil)
        if @cred
          @cred.is_working = (response.code == 200)
          @cred.updated_at = Time.current
          @cred.base_url = base_url if base_url && @cred&.base_url.blank?
          @cred.save
        else
          false
        end
      end

      def make_api_call(base_url)
        url = base_url + ENDPOINT

        request = HTTPI::Request.new
        request.headers = headers
        request.url = url

        resp = HTTPI.get(request)
        credential_is_working(resp)
        resp
      rescue Errno::ECONNRESET
        raise Datto::ConnectionPeerResetError
      end

      def zone_request
        request = HTTPI::Request.new
        request.url = "https://webservices.autotask.net/atservicesrest/v1.0/zoneInformation"
        request.headers = headers
        request.query = { "user" => username }
        response = HTTPI.get(request)
        unless response.code == 200
          error_str = "Datto zone request error. Code #{response.code} with message #{response.raw_body}"
          Rails.logger.error(error_str)
          return
        end
        body = JSON.parse(response.raw_body)

        [response.code, body]
      rescue Errno::ECONNRESET
        raise Datto::ConnectionPeerResetError
      end

      def headers
        {
          ApiIntegrationCode: ENV["DATTO_INTEGRATION_CODE"],
          UserName:           username,
          Secret:             secret_key,
          Accept:             "application/json"
        }.merge("Content-Type" => "application/json")
      end

      def username
        @username ||= (@cred&.datto_psa_username || @params[:username] || @params[:datto_psa_username])
      end

      def secret_key
        @secret_key ||= (@cred&.datto_psa_secret || @params[:secret_key] || @params[:datto_psa_secret])
      end
    end
  end
end
