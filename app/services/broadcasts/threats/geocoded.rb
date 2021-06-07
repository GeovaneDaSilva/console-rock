module Broadcasts
  module Threats
    # :nodoc
    class Geocoded < Base
      def initialize(geocoded_threat)
        @geocoded_threat = geocoded_threat
      end

      def call
        @geocoded_threat.account.self_and_all_ancestors.each do |account|
          next unless active_channel?(channel_name(account))

          ActionCable.server.broadcast(
            channel_name(account), geocoded_threat_data
          )
        end

        true
      end

      private

      def egress_ip
        @egress_ip ||= if @geocoded_threat.threatable.is_a?(Device)
                         @geocoded_threat.device.egress_ip
                       else
                         EgressIp.where(
                           customer: @geocoded_threat.account.self_and_all_descendants
                         ).sample
                       end
      end

      def channel_name(account)
        "account_#{account.id}:geocoded_threats"
      end

      def geocoded_threat_data
        ApplicationController.renderer.render(
          partial: "shared/threats/threat",
          locals:  { threat: @geocoded_threat, egress_ips: [egress_ip] }
        ).squish
      end
    end
  end
end
