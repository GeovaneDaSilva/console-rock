# :nodoc
module Sophos
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      def initialize(params)
        @params = params
        @cred = Credentials::Sophos.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        credential = build_credential
        code, _data = Sophos::Services::Authenticate.new(credential).make_api_call

        { code: code, error: (code != 200) }
      end

      private

      def build_credential
        Credentials::Sophos.new(
          account_id:           @cred&.account_id || @params[:account_id],
          sophos_client_id:     @cred&.sophos_client_id || @params[:sophos_client_id],
          sophos_client_secret: @cred&.sophos_client_secret || @params[:sophos_client_secret]
        )
      end
    end
  end
end
