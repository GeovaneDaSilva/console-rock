module Threats
  module Lookup
    # lookup a url
    class Url < Base
      include ApiClients::ApiLimits::VirusTotal

      def initialize(url, skip_safebrowser = false)
        super()

        @url              = url
        @skip_safebrowser = skip_safebrowser
      end

      def call
        known_bad?
        results
        log_lookup!

        if !known_bad? || results.nil? || results["response_code"] <= 0
          nil # Unknown
        else
          results.merge("threat_types" => known_threat_types)
        end
      end

      private

      def unknown_response?
        results["response_code"] <= 0
      end

      def cache_key
        "threats/url/v1/#{@url}"
      end

      def query_api!
        raise Threats::Lookup::ApiLimitExceeded if api_limit.exceeded?

        api_limit.increment!

        last_response = api_client.get do |req|
          req.url "url/report"
          req.params["apikey"]   = api_key
          req.params["resource"] = @url
          req.params["allinfo"]  = true
        end.body

        if !last_response.nil? && (last_response["response_code"]).positive?
          cache.write(cache_key, last_response, expires_in: 7.days)
        end

        last_response
      end

      def api_client
        @api_client ||= ApiClients::VirusTotal.new.call
      end

      def api_key
        ENV["VIRUS_TOTAL_API_KEY"]
      end

      def known_bad?
        return true if @skip_safebrowser

        @known_bad ||= known_threat_types.any?
      end

      def known_threat_types
        results = JSON.parse(known_bad_request.body)["matches"]
        return [] if results.blank?

        results.collect { |result| result["threatType"] }
      rescue JSON::ParserError, HTTPI::Error
        false
      end

      def known_bad_request
        @known_bad_request ||= HTTPI.post(
          HTTPI::Request.new(
            url:     "https://safebrowsing.rocketcyber.com/v4/threatMatches:find",
            headers: { "Content-Type": "application/json" },
            body:    {
              threatInfo: {
                threatEntryTypes: %w[URL],
                threatEntries:    [{ url: @url }]
              }
            }.to_json
          )
        )
      end

      def source
        return "safebrowsing" unless known_bad?
        return "cache" if cached_response.present?

        "virustotal"
      end
    end
  end
end
