module Threats
  module Evaluation
    # Determine if a URL is malicious or not
    # Checks for cached value, otherwise proceeds with lookup
    # Requeues job if the VT API limit has been reached
    class Url < Base
      include ::ApiClients::ApiLimits::VirusTotal

      private

      def trigger_requeue!
        return false if cache.read("threats/url/v1/#{threat_value}").present?
        return true if api_limit.exceeded?

        false
      end

      def lookup_klass
        Threats::Lookup::Url
      end

      def threat_type
        :url
      end

      def api_key
        ENV["VIRUS_TOTAL_API_KEY"]
      end
    end
  end
end
