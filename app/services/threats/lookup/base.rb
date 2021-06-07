module Threats
  module Lookup
    # :nodoc
    class Base
      def initialize
        @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def call
        response = results

        log_lookup!

        if response.nil? || unknown_response?
          nil # Unknown
        else
          response
        end
      end

      private

      def unknown_response?
        raise NotImplementedError
      end

      def cache_key
        raise NotImplementedError
      end

      def query_api!
        raise NotImplementedError
      end

      def cache
        Rails.application.config.threat_lookup_store
      end

      def old_cache
        Rails.application.config.old_threat_lookup_store
      end

      def results
        # results can be nil, so ||= doesn't work here
        @results = cached_response.presence || query_api! unless defined?(@results)

        @results
      end

      def cached_response
        @cached_response ||= cache.read(cache_key) || old_cache.read(cache_key)
      end

      def log_lookup!
        # Rails.logger.tagged("ThreatLookup") do
        #   Rails.logger.info "type=#{self.class.name} result_source=#{source} duration=#{duration}"
        # end
      end

      def duration
        Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time
      end

      def source
        return "cache" if cached_response.present?

        "opswat"
      end
    end
  end
end
