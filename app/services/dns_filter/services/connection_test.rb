# :nodoc
module DnsFilter
  # :nodoc
  module Services
    # :nodoc
    class ConnectionTest
      def initialize(params)
        @params = params
        @cred = Credentials::DnsFilter.find(params[:credential_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        credential = build_credential
        code, data = DnsFilter::Services::Authenticate.new(credential).make_api_call
        { code: code, error: (code != 200), message: data["error_description"] }
      end

      private

      def build_credential
        Credentials::DnsFilter.new(
          account_id:          @cred&.account_id || @params[:account_id],
          dns_filter_username: @cred&.dns_filter_username || @params[:dns_filter_username],
          dns_filter_password: @cred&.dns_filter_password || @params[:dns_filter_password]
        )
      end
    end
  end
end
