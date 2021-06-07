module Broadcasts
  module Devices
    # :nodoc
    class Status < Base
      include ActionView::Helpers::NumberHelper

      attr_reader :device

      def initialize(device)
        @device = device
      end

      def call
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, device_status.to_json

        true
      end

      private

      def channel_name
        "device_#{@device.id}:status"
      end

      def device_status
        {
          id:                       @device.id,
          updated_at:               @device.updated_at,
          status:                   @device.connectivity,
          status_text:              @device.status_text,
          hash_progress:            @device.hash_progress.to_i,
          malicious_indicators:     number_with_delimiter(@device.malicious_count),
          suspicious_indicators:    number_with_delimiter(@device.suspicious_count),
          informational_indicators: number_with_delimiter(@device.informational_count)
        }
      end
    end
  end
end
