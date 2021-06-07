# :nodoc
module Cylance
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include ErrorHelper
      include PostApiCallProcessor

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Cylance.find(cred) : cred
        @params = params
        @query = params.except(:url)
        @url = params[:url] || params["url"]
        @method = "get"
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Cylance) || @url.nil?
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        events
      end

      private

      def make_api_call(access_token)
        headers = {
          "Accept"        => "application/json",
          "Authorization" => "Bearer #{access_token}"
        }
        request = HTTPI::Request.new
        request.url = @url
        request.headers = headers
        request.query = @query

        if @method == "get"
          HTTPI.get(request)
        elsif @method == "put"
          HTTPI.put(request)
        elsif @method == "post"
          HTTPI.post(request)
        end
      end

      def events
        access_token = Cylance::Services::CredentialUpdater.new(@cred).call

        resp = make_api_call(access_token)
        credential_is_working(resp)

        return if html_error(__FILE__, resp)

        JSON.parse(resp.raw_body)
      end
    end
  end
end
