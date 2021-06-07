module Threats
  module Evaluation
    # Determine if Hash is malicious or not
    # Checks for cached value, otherwise proceeds with lookup
    # Requeues job if the Opswat limit has been reached
    class Hash < Base
      include ::ApiClients::ApiLimits::Opswat

      private

      def trigger_requeue!
        @known_safe = false

        return false if cache.read("threats/hash-opswat/v1/#{threat_value}").present?
        return false if known_safe?
        return true if api_limit.exceeded?

        false
      end

      def lookup_klass
        Threats::Lookup::Hash
      end

      def threat_type
        :hash
      end

      def lookup
        # Lookup can be nil, so ||= doesn't work here
        @lookup = lookup_klass.new(threat_value, true).call unless defined?(@lookup)

        @lookup
      end

      def api_key
        ENV["OPSWAT_API_KEY"]
      end

      def known_safe?
        @known_safe = HTTPI.get(
          HTTPI::Request.new(
            "https://nsrl.rocketcyber.com/#{threat_value}"
          )
        ).code == 200
      rescue HTTPI::Error
        false
      end
    end
  end
end
