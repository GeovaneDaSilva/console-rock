module Pipeline
  module Dependencies
    # Fetches and caches the App Config value
    class FetchAppConfig
      class NoAppConfigFound < StandardError; end

      def initialize(attribute = nil, app_result_id = nil)
        @app_result = Apps::Result.find_by(id: app_result_id)
        @account = Account.find_by(id: @app_result&.customer_id)
        @app_id = @app_result&.app_id
        @device_id = @app_result&.device_id
        @attribute = attribute
      end

      def call
        return if @app_result.nil?

        fetch_app_config
      rescue NoAppConfigFound
        message = "No APP CONFIG found - app_id: #{@app_id}"
        log_error(message)
      end

      private

      def fetch_app_config
        fetch_account_config || raise(NoAppConfigFound)
      end

      # This only works for account configs.  We'll worry about device configs later
      # (since we almost never use them in this context)
      def fetch_account_config(expiration = 15.minutes)
        key = ["pipeline_dependencies_fetchappconfig", @app_id, @account.id, @attribute]
        Rails.cache.fetch(key, expires_in: expiration) do
          config = Apps::AccountConfig.joins(:account).where(
            type: "Apps::AccountConfig", account_id: @account.self_and_ancestors.select(:id),
            app_id: @app_id
          ).order("accounts.path DESC").first&.merged_config
          if config.nil?
            app_template = App.find_by(id: @app_id)&.configuration_type
            config = APP_CONFIGS[app_template]
          end
          config = config&.dig(@attribute)

          process_app_config(config)
        end
      end

      # If the config is in some kind of weird format (e.g. signin_enabled_countries), fix that here.
      def process_app_config(config)
        # for now, just make it work with hashes that have an <ENABLED> attribute,
        # since that is the problem with signin_enabled_countries, which is what we're trying to get working
        return config unless config.is_a?(Hash) && config.values.first.include?("enabled")

        config.map { |key, value| key if value["enabled"] }.compact
      end

      def log_error(message)
        Rails.logger.error(message)
      end
    end
  end
end
