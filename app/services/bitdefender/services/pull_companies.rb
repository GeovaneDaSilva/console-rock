# :nodoc
module Bitdefender
  # :nodoc
  module Services
    # :nodoc
    class PullCompanies
      include PostApiCallProcessor

      def initialize(credential)
        @credential = credential
      end

      def call
        return unless @credential.is_a?(Credentials::Bitdefender)
        return if @credential.account.billing_account.paid_thru < DateTime.current

        resp = make_api_call
        credential_is_working(resp)
        companies = JSON.parse(resp.raw_body)["result"]
        # documentation does not give any way to paginate as of 5/5/21
        save(companies)
      end

      private

      def make_api_call
        base_64_token = Base64.encode64("#{@credential.access_token}:").delete("\n")
        headers = {
          "Content-Type"  => "application/json",
          "Authorization" => "Basic #{base_64_token}"
        }

        base = @credential&.bitdefender_url
        request = HTTPI::Request.new
        request.url = "#{base}/v1.0/jsonrpc/network"
        request.headers = headers
        request.body = {
          "id": SecureRandom.uuid, "jsonrpc": "2.0",
          "method": "getCompaniesList", "params": []
        }.to_json

        HTTPI.post(request)
      end

      def save(result)
        return if result.nil?

        result_to_array = result.map { |n| [n["id"], n["name"]] }
        @credential.update(sites: result_to_array)
      end
    end
  end
end
