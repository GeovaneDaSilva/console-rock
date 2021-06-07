module Apps
  module Configs
    # Convert a SuspiciousNetworkService params to a usable hash
    class SuspiciousNetworkService
      def initialize(params)
        @params = params
      end

      def merge(params)
        next_index = params["enabled_services"].to_h.keys.collect(&:to_i).max + 1

        params.tap do |hsh|
          hsh["enabled_services"] = hsh["enabled_services"].to_h.merge(next_index.to_s => to_h)
        end
      end

      def to_h
        if valid?
          {
            ports:        ports,
            protocol:     protocol,
            direction:    direction,
            service_name: service_name,
            description:  description,
            enabled:      attrs["enabled"]

          }
        else
          {}
        end
      end

      def valid?
        description.present? &&
          service_name.present? &&
          direction.present? &&
          protocol.present? &&
          ports.present?
      end

      private

      def attrs
        @attrs ||= @params.dig("custom", "suspicious_network_service").to_h
      end

      def ports
        @ports ||= attrs["ports"].split(",").collect(&:to_i).reject(&:blank?)
      end

      def protocol
        @protocol ||= attrs["protocol"]
      end

      def direction
        @direction ||= attrs["direction"]
      end

      def service_name
        @service_name ||= attrs["service_name"]
      end

      def description
        @description ||= attrs["description"]
      end
    end
  end
end
