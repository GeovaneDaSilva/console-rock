module Threats
  module Lookup
    # lookup a file hash
    class Hash < Base
      include ApiClients::ApiLimits::Opswat

      def initialize(hash, skip_nsrl = false)
        super()

        @hash      = hash
        @skip_nsrl = skip_nsrl
      end

      def call
        if cached_response.blank? && known_safe? # Early return safe
          log_lookup!
          {}
        else
          super
        end
      end

      private

      def unknown_response?
        results.dig(@hash.upcase) == "Not Found"
      end

      def cache_key
        "threats/hash-opswat/v1/#{@hash}"
      end

      def query_api!
        raise Threats::Lookup::ApiLimitExceeded if api_limit.exceeded?

        last_response = api_client.get("hash/#{@hash}")

        return if last_response.status == 404
        raise Threats::Lookup::ApiError if last_response.status >= 500 # Bad Response

        api_limit.increment(Integer(last_response.headers["x-ratelimit-used"]))

        raise Threats::Lookup::ApiLimitExceeded if last_response.status == 429 # Throttled

        return unless last_response.body.is_a?(::Hash)

        if last_response.body.dig("scan_results", "progress_percentage") == 100
          cache.write(cache_key, last_response.body, expires_in: 7.days)
        end

        last_response.body
      rescue Faraday::ParsingError
        raise Threats::Lookup::ApiError
      end

      def known_safe?
        return false if @skip_nsrl

        @known_safe ||= nsrl?
      end

      def nsrl?
        HTTPI.get(
          HTTPI::Request.new(
            "https://nsrl.rocketcyber.com/#{@hash}"
          )
        ).code == 200
      rescue HTTPI::Error
        false
      end

      def source
        return "nsrl" if known_safe?
        return "cache" if cached_response.present?

        "opswat"
      end

      def api_client
        @api_client ||= ApiClients::Opswat.new.call
      end

      def api_key
        ENV["OPSWAT_API_KEY"]
      end
    end
  end
end
