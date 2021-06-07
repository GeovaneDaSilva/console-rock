module Broadcasts
  module Devices
    # :nodoc
    class Hunt < Base
      def initialize(hunt_result)
        @hunt_result = hunt_result
        @device      = hunt_result.device
        @hunt        = hunt_result.hunt
        @revision    = hunt_result.revision
      end

      def call
        return
        hunt_channel = "device_#{@device.id}:hunt_#{@hunt.id}"
        rev_channel  = "device_#{@device.id}:hunt_#{@hunt.id}_#{@revision}"

        ActionCable.server.broadcast(hunt_channel, hunt_entry) if latest? && active_channel?(hunt_channel)
        ActionCable.server.broadcast(rev_channel, hunt_entry) if active_channel?(rev_channel)

        true
      end

      private

      def latest?
        @hunt.revision == @revision
      end

      def hunt_entry
        @hunt_entry ||= AuthenticatedController.renderer.render(
          partial: hunt_entry_template,
          locals:  {
            status: @hunt_result.prevailing_status, name: @hunt.name,
            hostname: @device.hostname, timestamp: @hunt_result.created_at,
            result_path: Rails.application.routes.url_helpers.device_r_hunt_path(@device, @hunt_result),
            device: @device, hunt: @hunt
          }
        ).squish
      end

      def hunt_entry_template
        @hunt.continuous? ? "hunts/continuous_hunt" : "hunts/device_hunt_results"
      end
    end
  end
end
