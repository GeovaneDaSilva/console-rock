module Threats
  module Lookup
    # lookup an IP's reputation
    class Ip < Base
      include ApiClients::ApiLimits::Opswat

      def initialize(ip)
        super()

        @ip = ip
      end

      private

      def results
        # results can be nil, so ||= doesn't work here
        unless defined?(@results)
          @results = invalid_ip_response.presence ||
                     cached_response.presence ||
                     query_api!
        end

        if @results && @results.dig("geo_info", "country", "code").blank?
          geo_lookup = Geocoder.search(@ip)&.first&.data&.with_indifferent_access

          @results["geo_info"] = { "country" => { "code" => geo_lookup[:country] } }
        end

        @results
      end

      def unknown_response?
        results.dig(@ip) == "Not Found"
      end

      def cache_key
        "threats/ip-opswat/v1/#{@ip}"
      end

      def query_api!
        raise Threats::Lookup::ApiLimitExceeded if api_limit.exceeded?

        last_response = api_client.get("ip/#{@ip}")

        raise Threats::Lookup::ApiError if last_response.status >= 500 # Bad Response

        api_limit.increment

        raise Threats::Lookup::ApiLimitExceeded if last_response.status == 429 # Rate Limited

        return if last_response.status == 404
        return unless last_response.body.is_a?(::Hash)

        results = last_response.body

        results["geo_info"].to_h.deep_merge(geo_info) if geo_lookup.present?

        if results.dig("lookup_results", "detected_by").present?
          cache.write(cache_key, results, expires_in: 7.days)
        end

        results
      rescue Faraday::ParsingError
        raise Threats::Lookup::ApiError
      end

      def api_client
        @api_client ||= ApiClients::Opswat.new.call
      end

      def api_key
        ENV["OPSWAT_API_KEY"]
      end

      def geo_lookup
        @geo_lookup ||= Geocoder.search(@ip)&.first&.data
      end

      def geo_info
        {
          "country"  => { "code" => geo_lookup["country"] },
          "location" => {
            "latitude"        => geo_lookup["loc"].to_s.split(",").first,
            "longitude"       => geo_lookup["loc"].to_s.split(",").last,
            "countryOrRegion" => geo_lookup["region"],
            "city"            => geo_lookup["city"]
          }.reject { |_k, v| v.blank? }
        }.reject { |_k, v| v.blank? }
      end

      def invalid_ip_response
        return unless invalid_ip?

        {
          lookup_results: { detected_by: 0 },
          geo_info:       { country: { code: "US" } }
        }.with_indifferent_access
      end

      def invalid_ip?
        address = IPAddress(@ip)

        !IPAddress.valid?(@ip.to_s) || address.loopback? || (address.ipv4? && (address.private? ||
          ![address.a?, address.b?, address.c?].uniq.include?(true))) || (address.ipv6? &&
          (address.mapped? || address.unspecified?))
      rescue IPAddr::InvalidAddressError
        false
      end

      def source
        return "faked" if invalid_ip?
        return "cache" if cached_response.present?

        "opswat"
      end
    end
  end
end
