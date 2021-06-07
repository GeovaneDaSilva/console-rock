# :nodoc
module Duo
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include ErrorHelper
      include PostApiCallProcessor

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Duo.find(cred) : cred
        @params = params
        @query = params.except(:url, :method, "url", "method")
        @url = params[:url] || params["url"]
        @method = params[:method] || params["method"] || "get"
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Duo) || @url.nil?
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        events
      end

      private

      def make_api_call
        uri = request_uri(@url, @query)
        current_date, signed = sign(@method, uri.host, @url, @query)

        headers = {
          "Accept"     => "application/json",
          "Date"       => current_date,
          "User-Agent" => "duo_api_ruby/1.1.0"
        }
        request = HTTPI::Request.new
        request.auth.basic(@cred.duo_integration_key, signed)
        request.url = uri
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
        credential_is_working(resp)

        return if html_error(__FILE__, resp)

        JSON.parse(resp.raw_body)
      end

      def encode_key_val(k, v)
        # encode the key and the value for a url
        URI.encode_www_form([[k.to_s, v.to_s]])
      end

      def encode_params(params_hash = nil)
        return "" if params_hash.nil?

        params_hash.sort.map do |k, v|
          # when it is an array, we want to add that as another param
          # eg. next_offset = ['1547486297000', '5bea1c1e-612c-4f1d-b310-75fd31385b15']
          if v.is_a?(Array)
            encode_key_val(k, v[0]) + "&" + encode_key_val(k, v[1])
          else
            encode_key_val(k, v)
          end
        end.join("&")
      end

      def time
        Time.current.rfc2822
      end

      def request_uri(path, params = nil)
        u = "https://" + @cred.duo_host + path
        u += "?" + encode_params(params) unless params.nil?
        URI.parse(u)
      end

      def canonicalize(method, host, path, params, options = {})
        options[:date] ||= time
        canon = [
          options[:date],
          method.upcase,
          host.downcase,
          path,
          encode_params(params)
        ]
        [options[:date], canon.join("\n")]
      end

      def sign(method, host, path, params, options = {})
        date, canon = canonicalize(method, host, path, params, date: options[:date])
        [date, OpenSSL::HMAC.hexdigest("sha1", @cred.duo_secret, canon)]
      end
    end
  end
end
