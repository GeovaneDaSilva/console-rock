module Threats
  module Evaluation
    # Base evaluation class, intended to be inherited from
    class Base
      attr_reader :device, :threat_value, :meta

      def initialize(device, threat_value, meta)
        @device       = device
        @threat_value = threat_value
        @meta         = JSON.parse(meta)
      end

      def call
        return requeue! if trigger_requeue!

        respond_to_device

        # Rails.logger.tagged("ThreatEvaluation") do
        #   Rails.logger.info "type=#{lookup_klass.name} device_id=#{@device.id}
        # threat_value=#{@threat_value}"
        # end
      rescue Lookup::ApiLimitExceeded, TrafficJam::Errors::LimitExceededError, Lookup::ApiError,
             Faraday::Error
        requeue!
      end

      private

      def cache
        Rails.application.config.threat_lookup_store
      end

      def lookup_klass
        raise NotImplementedError
      end

      def threat_type
        raise NotImplementedError
      end

      def lookup
        # Lookup can be nil, so ||= doesn't work here
        @lookup = lookup_klass.new(threat_value).call unless defined?(@lookup)

        @lookup
      end

      def respond_to_device
        ServiceRunnerJob.set(queue: :threat_evaluation)
                        .perform_later("DeviceBroadcasts::Device", device.id, response.to_json, true)
      end

      def response
        {
          type: "threat_indicator", payload: {
            type: threat_type,
            threat_type.to_s => threat_value,
            status: status,
            details: lookup.to_h,
            meta: meta
          }
        }
      end

      def status
        return "benign" if lookup.is_a?(Hash) && lookup.empty?
        return "unknown" if lookup.nil?

        "positive"
      end

      # Override to do API Limit checks, etc
      # Return true to requeue
      def trigger_requeue!
        false
      end

      def requeue!
        ServiceRunnerJob.set(wait: rand(15..90).minutes, queue: :threat_evaluation)
                        .perform_later(self.class.name, device, threat_value, meta.to_json)
      end
    end
  end
end
