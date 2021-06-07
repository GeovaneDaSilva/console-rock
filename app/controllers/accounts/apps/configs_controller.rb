module Accounts
  module Apps
    # Configure app
    class ConfigsController < AuthenticatedController
      include Configable

      def update
        authorize account, :can_manage_apps?
        if !params[:config].nil? && app_config.update(config: cast_value(config_params))
          broadcast_app_check!

          flash[:notice] = "Updated configuration of the #{app.title} App successfully"
        else
          flash[:error] = "Configuration update for the #{app.title} App failed"
        end

        redirect_back fallback_location: root_path
      end

      def destroy
        authorize account, :can_manage_apps?

        if app_config.destroy
          broadcast_app_check!
          flash[:notice] = "Removal of configuration of the #{app.title} App \
                            for #{account.name} successful"
        else
          flash[:error] = "Removal of configuration for the #{app.title} App \
                          for #{account.name} failed"
        end

        redirect_back fallback_location: root_path
      end

      private

      def account
        @account ||= policy_scope(Account).find(params[:account_id])
      end

      def app
        @app ||= App.find(params[:app_id])
      end

      def app_config
        @app_config ||= account.app_configs.find_or_initialize_by(app: app)
      end

      def broadcast_app_check!
        account.self_and_all_descendant_customers.each do |customer|
          ServiceRunnerJob.perform_later(
            "DeviceBroadcasts::Customer", customer,
            { type: "app_config_update", payload: { app_id: app.id } }.to_json
          )
        end
      end

      def config_params
        result = ::Apps::Configs::Base.new(params.permit!).merge(params[:config].permit!.to_h)
        if app.configuration_type == "data_discovery"
          result["scan_types"]["payment_card"]["keywords"] = \
            params.dig("config", "scan_types", "payment_card", "keywords")&.split("\r\n")

          result["scan_types"]["payment_card"]["enabled_brands"] =
            params.dig("config", "scan_types", "payment_card", "enabled_brands").to_h.collect do |k, v|
              k if v == "true"
            end.compact

          (params.dig("config", "scan_types") || {}).except("payment_card").each do |k, _v|
            result = ::Apps::Configs::DataDiscovery.new(params.permit!,
                                                        ["scan_types", k]).merge(result)
          end
        end
        result
      end
    end
  end
end
