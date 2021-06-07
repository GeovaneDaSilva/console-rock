module Threats
  module Evaluation
    # Determine if an IP is malicious or not
    # Checks for cached value, otherwise proceeds with lookup
    # Requeues job if the VT API limit has been reached
    class Ip < Base
      include ::ApiClients::ApiLimits::Opswat

      private

      def trigger_requeue!
        return false if cache.read("threats/ip-opswat/v1/#{threat_value}").present?
        return true if api_limit.exceeded?

        false
      end

      def status
        return "unknown" if lookup.nil?
        return "benign" if lookup.is_a?(Hash) && !lookup.dig("lookup_results", "detected_by").positive?

        "positive"
      end

      def lookup_klass
        Threats::Lookup::Ip
      end

      def lookup
        # Lookup can be nil, so ||= doesn't work here
        @lookup = lookup_klass.new(threat_value).call unless defined?(@lookup)

        @lookup
      end

      def threat_type
        :ip
      end

      def api_key
        ENV["OPSWAT_API_KEY"]
      end
    end
  end
end
