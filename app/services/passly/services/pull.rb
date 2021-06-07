# :nodoc
module Passly
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include ErrorHelper
      include PostApiCallProcessor

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Passly.find(cred) : cred
        @params = params
        @query = params.except(:url, :method)
        @url = params[:url] || params["url"]
        @method = params[:method] || "get"
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Passly) || @url.nil?
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current
        return if @cred.account_id == 2

        process
      end

      private

      def make_api_call(access_token)
        request = HTTPI::Request.new
        request.url = @url
        request.headers = { "Authorization" => "Bearer #{access_token}" }
        request.query = @query

        if @method == "get"
          HTTPI.get(request)
        elsif @method == "put"
          HTTPI.put(request)
        elsif @method == "post"
          HTTPI.post(request)
        end
      end

      def process
        access_token = Passly::Services::CredentialUpdater.new(@cred).call

        resp = make_api_call(access_token)
        credential_is_working(resp)

        return if html_error(__FILE__, resp)

        JSON.parse(resp.raw_body)
      end
    end
  end
end
