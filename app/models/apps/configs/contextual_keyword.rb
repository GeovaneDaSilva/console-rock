module Apps
  module Configs
    # Convert a Contextual Keyword params to a usable hash
    class ContextualKeyword
      def initialize(params, hash_key = "keywords", params_key = "contextual_keyword")
        @params = params
        @hash_key = hash_key
        @params_key = params_key
      end

      def merge(params)
        params.tap do |hsh|
          hsh[@hash_key] = hsh[@hash_key].to_h.merge(to_h)
        end
      end

      def to_h
        if valid?
          {
            attrs["label"] => {
              value:   attrs["value"],
              type:    attrs["type"],
              enabled: attrs["enabled"]
            }
          }
        else
          {}
        end
      end

      def valid?
        attrs["label"].present? &&
          attrs["value"].present? &&
          attrs["type"].present?
      end

      private

      def attrs
        @attrs ||= @params.dig("config", *[@params_key].flatten).to_h
      end
    end
  end
end
