module Apps
  module Configs
    # Convert a SuspiciousEvent params to a usable hash
    class SuspiciousEvent
      def initialize(params)
        @params = params
      end

      def merge(params)
        params["macos_enabled_events"] = params["macos_enabled_events"].to_h.merge(custom_macos_event)
        params["enabled_events"] = params["enabled_events"].to_h.merge(custom_windows_event)

        params
      end

      def custom_windows_event
        custom_windows_event_from_log.presence || custom_windows_event_from_channel
      end

      def custom_windows_event_from_log
        if custom_windows_event_from_log_valid?
          {
            custom_windows_event_attrs["log_event_id"] => {
              event_id:    custom_windows_event_attrs["log_event_id"].to_i,
              log_name:    custom_windows_event_attrs["log_name"],
              description: custom_windows_event_attrs["log_description"],
              verdict:     (custom_windows_event_attrs["log_verdict"] || "Suspicious").parameterize,
              enabled:     custom_windows_event_attrs["log_enabled"]
            }
          }
        else
          {}
        end
      end

      def custom_windows_event_from_channel
        if custom_windows_event_from_channel_valid?
          {
            custom_windows_event_attrs["channel_event_id"] => {
              event_id:     custom_windows_event_attrs["channel_event_id"].to_i,
              description:  custom_windows_event_attrs["channel_description"],
              channel_path: custom_windows_event_attrs["channel_path"],
              verdict:      (custom_windows_event_attrs["channel_verdict"] || "Suspicious").parameterize,
              query:        custom_windows_event_attrs.fetch("query", "*"),
              enabled:      custom_windows_event_attrs["channel_enabled"]
            }
          }
        else
          {}
        end
      end

      def custom_macos_event
        if custom_macos_event_valid?
          {
            custom_macos_event_attrs["event_id"] => {
              event_id:    custom_macos_event_attrs["event_id"],
              filter:      custom_macos_event_attrs["filter"],
              description: custom_macos_event_attrs["description"],
              verdict:     (custom_macos_event_attrs["verdict"] || "Suspicious").parameterize,
              enabled:     custom_macos_event_attrs["enabled"]
            }
          }
        else
          {}
        end
      end

      def custom_windows_event_from_log_valid?
        custom_windows_event_attrs["log_description"].present? &&
          custom_windows_event_attrs["log_event_id"].present? &&
          custom_windows_event_attrs["log_name"].present?
      end

      def custom_windows_event_from_channel_valid?
        custom_windows_event_attrs["channel_description"].present? &&
          custom_windows_event_attrs["channel_event_id"].present? &&
          custom_windows_event_attrs["query"].present? &&
          custom_windows_event_attrs["channel_path"].present?
      end

      def custom_macos_event_valid?
        custom_macos_event_attrs["description"].present? &&
          custom_macos_event_attrs["event_id"].present? &&
          custom_macos_event_attrs["filter"].present?
      end

      private

      def custom_windows_event_attrs
        @custom_windows_event_attrs ||= @params.dig("custom", "suspicious_event").to_h
      end

      def custom_macos_event_attrs
        @custom_macos_event_attrs ||= @params.dig("custom", "macos_suspicious_event").to_h
      end
    end
  end
end
