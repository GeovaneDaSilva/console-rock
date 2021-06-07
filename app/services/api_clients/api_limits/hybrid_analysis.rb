module ApiClients
  module ApiLimits
    # Hybrid Analysis API limit configuration
    module HybridAnalysis
      private

      def api_key
        raise NotImplmentedError
      end

      def api_limit
        @api_limit ||= TrafficJam::Limit.new(
          :hybrid_analysis_api_limit,
          api_key,
          max:    Rails.application.config.hybrid_analysis_api_limit,
          period: Rails.application.config.hybrid_analysis_api_limit_duration # seconds
        )
      end
    end
  end
end
