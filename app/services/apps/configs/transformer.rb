module Apps
  module Configs
    # Transform how app configs are stored internally
    # vs what the agent expects
    class Transformer
      def initialize(config_hash)
        @config_hash = config_hash.to_h
      end

      def call
        @config_hash.merge!(advanced_breach_detection_transformer)

        %w[
          enabled_countries enabled_events enabled_services
          enabled_installer_signatures enabled_filename_signatures
          enabled_interesting_ports
        ].each { |key| select_enabled!(key) }

        @config_hash
      end

      private

      # Stored as enabled_countries: {"US" => {enabled: false }, {"CN" => {enabled: true }
      # expects enabled_countries: ["CN"]
      def advanced_breach_detection_transformer
        return {} if @config_hash["enabled_ttps"].blank?

        results = { "enabled_ttps" => [] }
        @config_hash["enabled_ttps"].each do |ttp_id, ttp_config|
          results["enabled_ttps"] << ttp_id if ttp_config["enabled"] == true
        end

        results
      end

      # For config_key => { key: { ..., enabled: true }}
      # Rejects keys which the config_key.enabled != true
      def select_enabled!(config_key)
        return if @config_hash[config_key].blank?

        @config_hash[config_key].select! do |_key, key_config|
          key_config["enabled"] == true
        end
      end
    end
  end
end
