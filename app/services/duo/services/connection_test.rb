# :nodoc
module Duo
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      include ErrorHelper

      def initialize(params)
        @params  = params
        @cred    = Credentials::Duo.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        cred = Credentials::Duo.new
        cred.assign_attributes(
          {
            duo_host:            @cred&.duo_host || @params[:duo_host],
            duo_secret:          @cred&.duo_secret || @params[:duo_secret],
            duo_integration_key: @cred&.duo_integration_key || @params[:duo_integration_key],
            account_id:          @cred&.account_id || @params[:account_id]
          }
        )
        resp = Duo::Services::Pull.new(cred, { url: "/auth/v2/ping" }).call
        resp.dig("stat") == "OK"
      rescue SocketError
        false
      end
    end
  end
end
