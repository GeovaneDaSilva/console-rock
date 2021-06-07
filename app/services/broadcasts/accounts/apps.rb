module Broadcasts
  module Accounts
    # :nodoc
    class Apps < Base
      def initialize(app, scope_account, _ = nil)
        @app           = app
        @scope_account = scope_account
      end

      def call
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, payload.to_json

        true
      end

      private

      def channel_name
        "app:#{@app.id}:#{@scope_account.id}"
      end

      def detections
        @scope_account.all_descendant_app_counter_caches.where(
          app: @app
        )
      end

      def enabled?
        account_app? || app_enabled_on_child_account?
      end

      def account_app?
        AccountApp.where(account: @scope_account.self_and_ancestors, app: @app)
                  .where(disabled_at: nil)
                  .where.not(enabled_at: nil)
                  .order(account_id: :asc)
                  .exists?
      end

      def app_enabled_on_child_account?
        AccountApp.where(account: @scope_account.self_and_all_descendants, app: @app)
                  .where(disabled_at: nil)
                  .where.not(enabled_at: nil)
                  .any?
      end

      def payload
        case @app.configuration_type
        when "office365", "office365_signin", "powershell_runner", "syslog"
          cloud_app_payload
        else
          device_app_payload
        end
      end

      def device_app_payload
        {
          total_devices:     @scope_account.all_descendant_devices.size,
          reporting_devices: detections.with_detections.select(:device_id).distinct.count,
          detection_count:   detections.sum(:count),
          enabled:           enabled?
        }
      end

      def cloud_app_payload
        {
          total_instances: billable_instances,
          detection_count: detections.sum(:count),
          enabled:         enabled?
        }
      end

      def billable_instances
        case @app.configuration_type
        when "office365", "office365_signin", "powershell_runner"
          @scope_account.all_descendant_billable_instances.office_365_mailbox.active.size
        when "syslog"
          @scope_account.all_descendant_billable_instances.firewall.size
        else
          0
        end
      end
    end
  end
end
