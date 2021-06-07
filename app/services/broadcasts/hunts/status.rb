module Broadcasts
  module Hunts
    # :nodoc
    class Status < Base
      def initialize(hunt)
        @hunt = hunt
      end

      def call
        return
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, hunt_status.to_json

        true
      end

      private

      def channel_name
        "hunt_#{@hunt.id}:status"
      end

      def hunt_status
        {
          id:                             @hunt.id,
          updated_at:                     @hunt.updated_at,
          total_device_count:             @hunt.group.device_count,
          reported_device_count:          @hunt.reported_device_count,
          positive_reported_device_count: @hunt.reported_positive_device_count
        }
      end
    end
  end
end
