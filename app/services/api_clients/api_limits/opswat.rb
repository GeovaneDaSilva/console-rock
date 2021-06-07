module ApiClients
  module ApiLimits
    # Opswat Analysis API limit configuration
    module Opswat
      private

      def api_key
        raise NotImplmentedError
      end

      def api_limit
        @api_limit ||= TrafficJam::Limit.new(
          :opswat_api_limit,
          api_key,
          max:    Rails.application.config.opswat_api_limit,
          period: Rails.application.config.opswat_api_limit_duration # seconds
        )
      end
    end
  end
end
