module Apps
  module Configs
    # Convert a DataDiscovery params to a usable hash
    class DataDiscovery
      def initialize(params, params_key = "data_discovery")
        @params = params
        @params_key = params_key
      end

      def merge(params)
        params.tap do |hsh|
          hsh["scan_types"] = hsh["scan_types"].to_h.merge(to_h)
        end
      end

      def to_h
        if valid?
          {
            attrs["key"] => {
              "label"               => attrs["label"],
              "regex"               => regex,
              "keywords"            => keywords,
              "reporting_threshold" => attrs["reporting_threshold"],
              "enabled"             => ActiveModel::Type::Boolean.new.cast(attrs["enabled"] || true)
            }
          }
        else
          {}
        end
      end

      def valid?
        attrs["key"].present? &&
          attrs["label"].present? &&
          attrs["regex"].present? &&
          attrs["reporting_threshold"].present?
      end

      private

      def regex
        if attrs["regex"].is_a?(String)
          attrs["regex"].split(/[\r\n]/).reject(&:empty?)
        else
          attrs["regex"]
        end
      end

      def keywords
        if attrs["keywords"].is_a?(String)
          attrs["keywords"].split(/[\r\n]/).reject(&:empty?)
        else
          attrs["keywords"]
        end
      end

      def attrs
        @attrs ||= @params.dig("config", *[@params_key].flatten).to_h
      end
    end
  end
end
