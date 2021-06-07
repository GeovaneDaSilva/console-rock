module Threats
  module Ml
    # Submits the app result to ML
    class Submit
      URL = "#{ENV.fetch('THREAL_ML_HOST', 'http://localhost:5000')}/api/makecalc/".freeze

      def initialize(app_result)
        @app_result = app_result
      end

      def call
        return unless Rails.application.config.submit_ml
        return unless @app_result.details.type == "SuspiciousNetworkService"

        # calls the ML to determine confidence
        request.body = body
        response = http.request(request)

        @app_result.update(confidence: JSON.parse(response.body)["confidence"])
      end

      private

      def uri
        @uri ||= URI.parse(URL)
      end

      def http
        @http ||= Net::HTTP.new(uri.host, uri.port).tap { |h| h.use_ssl = uri.scheme == "https" }
      end

      def request
        @request ||= Net::HTTP::Post.new(uri.request_uri, headers)
      end

      def headers
        {
          "Content-Type":  "application/json",
          "Authorization": hmac
        }
      end

      def body
        @body ||= @app_result.to_json.force_encoding("UTF-8")
      end

      def digest
        @digest ||= OpenSSL::Digest.new("sha256")
      end

      def hmac
        @hmac ||= OpenSSL::HMAC.hexdigest(digest, ENV.fetch("THREAT_ML_SECRET", "supersecret"), body)
      end
    end
  end
end
