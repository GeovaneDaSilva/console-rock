module ApiClients
  module ApiLimits
    # IpInfo.io API limit configuration
    module IpInfo
      private

      def api_key
        raise NotImplmentedError
      end

      def api_limit
        @api_limit ||= TrafficJam::Limit.new(
          :ip_info_api_limit,
          api_key,
          max:    8_050, # limit of ~250k req/month
          period: 86_400 # seconds
        )
      end
    end
  end
end
