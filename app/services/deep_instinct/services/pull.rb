# :nodoc
module DeepInstinct
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include ErrorHelper
      include PostApiCallProcessor

      def initialize(cred, params = {})
        @cred = cred
        @params = params
        @url = params[:url]
        @method = params[:method] || "get"
        @wait = rand(30..60).minutes
      rescue TypeError
        @url = nil
        @method = nil
      end

      def call
        return if @cred.nil? || @method.nil? || @url.nil?
        return if !@cred.instance_of?(Credentials::DeepInstinct)

        events
      end

      private

      def make_api_call(token)
        headers = {
          "Content-Type"  => "application/json",
          "Authorization" => token
        }
        request = HTTPI::Request.new
        request.url = @url
        request.headers = headers
        request.query = @params.reject { |k, _v| %i[url method last_id once_only].include? k.to_sym }
        request.body = {}.to_json

        if @method == "get"
          HTTPI.get(request)
        elsif @method == "put"
          HTTPI.put(request)
        elsif @method == "post"
          HTTPI.post(request)
        end
      end

      def events
        resp = make_api_call @cred.access_token
        credential_is_working(resp)

        return if html_error(__FILE__, resp)

        JSON.parse(resp.raw_body)
      end
    end
  end
end
