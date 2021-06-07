module Broadcasts
  module Hunts
    # :nodoc
    class Start < Base
      def initialize(hunt, device)
        @hunt   = hunt
        @device = device
      end

      def call
        return
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, hunt_entry

        true
      end

      private

      def channel_name
        "device_#{@device.id}:hunt_#{@hunt.id}_#{@hunt.revision}"
      end

      def hunt_entry
        AuthenticatedController.renderer.render(
          partial: "hunts/device_hunt_results",
          locals:  {
            status: "running", name: @hunt.name,
            hostname: @device.hostname, timestamp: DateTime.current,
            result_path: nil, device: @device, hunt: @hunt
          }
        ).squish
      end
    end
  end
end
