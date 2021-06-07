module Broadcasts
  module Devices
    # :nodoc
    class Logs < Base
      def initialize(device, log = nil)
        @device = device
        @log    = log
      end

      def call
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, device_list

        true
      end

      private

      def channel_name
        "device_#{@device.id}:logs"
      end

      def logs
        if @log
          [@log]
        else
          @device.logs.all(limit: 50)
        end
      end

      def device_list
        AuthenticatedController.renderer.render(
          partial: "shared/device/logs", locals: { device: @device, logs: logs }
        ).squish
      end
    end
  end
end
