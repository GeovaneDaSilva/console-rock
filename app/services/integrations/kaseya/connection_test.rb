module Integrations
  module Kaseya
    # Ping an API endpoint
    class ConnectionTest
      def initialize(params)
        @params = params[:credentials_kaseya] || params
        @cred = Credentials::Kaseya.find(@params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        credential = build_credential
        code, _data = Integrations::Kaseya::Authenticate.new(credential).generate_token
        { code: code, error: (code != 200) }
      rescue ArgumentError
        { code: "(Invalid credentials)", error: true }
      end

      private

      def build_credential
        return @cred if @cred

        # TODO: I don't think there is ever a need for the secondary options here, verify and remove
        ::Credentials::Kaseya.new(
          kaseya_username: @params[:kaseya_username] || @params[:username],
          kaseya_password: @params[:kaseya_password] || @params[:password],
          kaseya_tenant:   @params[:kaseya_tenant] || @params[:company_name],
          base_url:        @params[:base_url]
        )
      end
    end
  end
end
