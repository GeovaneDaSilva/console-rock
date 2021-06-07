module ApiClients
  module ApiLimits
    # VirusTotal API limit configuration
    module VirusTotal
      private

      def api_key
        raise NotImplmentedError
      end

      def api_limit
        @api_limit ||= TrafficJam::Limit.new(
          :virus_total_api_limit,
          api_key,
          max:    Rails.application.config.virus_total_api_limit,
          period: Rails.application.config.virus_total_api_limit_duration # seconds
        )
      end
    end
  end
end
