module Broadcasts
  module Accounts
    # :nodoc
    class Defender < Base
      def initialize(account)
        @account = account
      end

      def call
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, payload

        true
      end

      private

      def channel_name
        "account:#{@account.id}:defender"
      end

      def devices
        @account.all_descendant_devices
      end

      def app_results
        @account.all_descendant_app_results.joins(:app).where(
          apps: { configuration_type: :defender }
        )
      end

      def payload
        {
          devices:    [
            { name: "Healthy",   value: devices.defender_health_status_healthy.size },
            { name: "Unhealthy", value: devices.defender_health_status_unhealthy.size },
            { name: "Unknown",   value: devices.defender_health_status_unknown.size }
          ],
          detections: [
            { name: "Malicious",     value: app_results.malicious.size },
            { name: "Suspicious",    value: app_results.suspicious.size },
            { name: "Informational", value: app_results.informational.size }
          ]
        }.to_json
      end
    end
  end
end
