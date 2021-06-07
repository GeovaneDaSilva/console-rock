module Apps
  # STI configuration for an app, scoped to device or account
  class Config < ApplicationRecord
    audited

    belongs_to :app

    def merged_config
      merged = deep_merge(parent_config, config)

      if merged["admin_configs"].is_a?(Array)
        new_admin_config = {}

        merged["admin_configs"].each do |admin_config_hash|
          new_admin_config[admin_config_hash["key"]] = admin_config_hash["value"]
        end

        merged.merge("admin_configs" => new_admin_config)
      else
        merged
      end
    end

    def config=(val)
      diffed = deep_diff(parent_config, val)

      super(diffed)
    end

    def default_config
      APP_CONFIGS[app.configuration_type] || {}
    end

    def parent_config
      inheritance_tree.first&.merged_config || default_config
    end

    def inheritance_tree
      raise NotImplementedError
    end

    # Returns the difference of the two hashes
    # a = { 1: { enabled: true }, 2: { enabled: true } }
    # b = { 1: { enabled: true }, 2: { enabled: false } }
    # Returns { "2" => { "enabled" => false }  }
    def deep_diff(a, b)
      a = a.to_h.with_indifferent_access.tap(&:stringify_keys!)
      b = b.to_h.with_indifferent_access.tap(&:stringify_keys!)
      diff = {}

      a.each do |k, v|
        if v.is_a?(Hash)
          diff[k] = deep_diff(a[k], b[k])
        elsif v.is_a?(Array)
          b_array = object_split(b[k])
          diff[k] = (a[k] + b_array).uniq - a[k]
        else
          diff[k] = b[k] unless a[k] == b[k]
        end
      end

      # Add all keys that exist in b, but not in a, like admin configs
      (b.keys - a.keys).each do |k|
        diff[k] = b[k]
      end

      diff.reject { |_k, v| v.nil? }
          .reject { |_k, v| v.respond_to?(:empty?) && v.empty? }
    end

    # Merges b into a, with b overriding values in a
    # similar to Hash#deep_merge, but will merge arrays
    def deep_merge(a, b)
      a = a.to_h.with_indifferent_access.tap(&:stringify_keys!)
      b = b.to_h.with_indifferent_access.tap(&:stringify_keys!)
      result = {}

      a.each do |k, v|
        result[k] = if v.is_a?(Hash)
                      deep_merge(a[k], b[k].to_h)
                    elsif v.is_a?(Array)
                      (a[k] + b[k].to_a).uniq
                    else
                      b[k].nil? ? a[k] : b[k]
                    end
      end

      (b.keys - a.keys).each do |k|
        result[k] = b[k]
      end

      result
    end

    private

    def object_split(o)
      o.to_a
    rescue NoMethodError
      o.split(/[\r\n]/).to_a
    end
  end
end
