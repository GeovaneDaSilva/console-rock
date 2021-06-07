module Apps
  module Results
    # Whitelists and Destroys App Results
    class Whitelister
      # app => App, scope => Account or Device,
      # params
      def initialize(key, app, scope, params)
        @key = key
        @app = app
        @scope = scope
        @params = params.with_indifferent_access
      end

      def call
        add_whitelist_entries!
        broadcast_app_check!
        remove_existing!
        resolve_incident!

        Rails.cache.write(@key, "completed")
      end

      private

      def add_whitelist_entries!
        @params[:whitelist].to_h.each do |whitelist_type, entries|
          entries.each do |entry|
            Apps::Results::Whitelist::Base.new(
              @app, @scope, entry, app_whitelist_config.dig(whitelist_type, :config_path)
            ).call
          end
        end
      end

      def resolve_incident!
        return if @params["incident_id"].blank?

        incident = Apps::Incident.find(@params["incident_id"])

        begin
          incident.results.each do |app_result|
            app_config = app_result.app.app_configs.where(device_id: nil, account_id: @scope.id).first
            w_options = app_result.whitelistable_options

            raise StopIteration if app_config.blank? || w_options.blank?

            w_options.each do |key, set|
              config_key = APP_WHITELISTS.dig(app_result.app.configuration_type, key, "config_path")

              raise StopIteration if config_key.blank?

              set.each do |value|
                raise StopIteration unless app_config.config.dig(*config_key)&.include? value
              end
            end
          end
        rescue StopIteration
          return
        end

        incident.update(state: :resolved, resolved_at: DateTime.current, resolver_id: @scope.id)
      end

      def remove_existing!
        return unless @params["remove_existing"] == "true"

        @params[:whitelist].to_h.each do |whitelist_type, entries|
          entries.each do |entry|
            app_whitelist_config.dig(whitelist_type, :result_paths).each do |result_path|
              Apps::Results::Whitelist::Destroyer.new(
                @app, @scope, entry, result_path
              ).call
            end
          end
        end
      end

      def broadcast_app_check!
        if @scope.is_a?(Device)
          broadcast_device_app_check!
        else
          broadcast_account_app_check!
        end
      end

      def broadcast_device_app_check!
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Device", @scope.id, broadcast_json
        )
      end

      def broadcast_account_app_check!
        return if @app.is_a?(Apps::CloudApp)

        @scope.self_and_all_descendant_customers.each do |customer|
          ServiceRunnerJob.perform_later(
            "DeviceBroadcasts::Customer", customer, broadcast_json
          )
        end
      end

      def broadcast_json
        @broadcast_json ||= { type: "app_config_update", payload: { app_id: @app.id } }.to_json
      end

      def app_whitelist_config
        APP_WHITELISTS.dig(@app.configuration_type)
      end
    end
  end
end
