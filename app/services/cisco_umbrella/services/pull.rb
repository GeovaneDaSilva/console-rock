# :nodoc
module CiscoUmbrella
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include ErrorHelper

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::CiscoUmbrella.find(cred) : cred
        @query = params.except(:url, :method)
        @url = params[:url] || params["url"]
        @method = params[:method] || "get"
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::CiscoUmbrella) || @url.nil?
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        events
      end

      private

      def make_api_call
        headers = {
          "Accept"        => "application/json",
          "Authorization" => "Basic #{@cred.base64}"
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
        resp = make_api_call
        return if html_error(__FILE__, resp)

        JSON.parse(resp.raw_body)
      end
    end
  end
end
