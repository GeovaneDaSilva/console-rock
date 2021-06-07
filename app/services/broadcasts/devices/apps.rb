module Broadcasts
  module Devices
    # :nodoc
    class Apps < Base
      def initialize(app, device)
        @app    = app
        @device = device
      end

      def call
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, payload
      end

      private

      def channel_name
        "device_apps:#{@app.id}:#{@device.id}"
      end

      def detections
        @device.app_counter_caches.where(app: @app)
      end

      def payload
        {
          detection_count: detections.sum(:count),
          enabled:         account_app&.enabled_at.present?
        }.to_json
      end

      def account_app
        @account_app ||= AccountApp.where(
          account:     @device.customer.self_and_all_ancestors,
          disabled_at: nil
        ).where.not(
          enabled_at: nil
        ).order("account_id ASC").first
      end
    end
  end
end
