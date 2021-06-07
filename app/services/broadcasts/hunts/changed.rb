module Broadcasts
  module Hunts
    # Broadcast updates for new or changed hunts
    class Changed < Base
      def initialize(hunt)
        @hunt  = hunt
        @group = hunt.group
      end

      def call
        return
        query = @group.device_query.recently_connected.page(0).per(100)

        until query.current_page > query.total_pages
          query.each { |device| broadcast_for_device(device) }

          query = @group.device_query.recently_connected.page(query.current_page + 1).per(100)
        end

        true
      end

      private

      def broadcast_for_device(device)
        hunt_channel = "device_#{device.id}:hunt_#{@hunt.id}"
        ActionCable.server.broadcast(hunt_channel, hunt_entry(device)) if active_channel?(hunt_channel)

        rev_channel = "device_#{device.id}:hunt_#{@hunt.id}_#{@hunt.revision}"
        ActionCable.server.broadcast(rev_channel, hunt_entry(device)) if active_channel?(rev_channel)
      end

      def timestamp(device)
        @hunt.hunt_results.where(device: device).last&.created_at || @hunt.updated_at
      end

      def hunt_entry(device)
        AuthenticatedController.renderer.render(
          partial: "hunts/device_hunt_results",
          locals:  {
            status: "pending", name: @hunt.name,
            hostname: device.hostname, timestamp: timestamp(device),
            result_path: nil,
            device: device, hunt: @hunt
          }
        ).squish
      end
    end
  end
end
