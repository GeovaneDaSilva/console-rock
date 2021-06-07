module Accounts
  module Apps
    # Account apps whitelists
    class WhitelistsController < AuthenticatedController
      helper_method :account, :whitelists

      def index
        authorize account, :manage_whitelists?
      end

      private

      def account
        @account ||= policy_scope(Account).find(params[:account_id])
      end

      def accounts
        @accounts ||= account.self_and_all_descendants
      end

      def account_configs
        account_ids = accounts.pluck(:id)
        @account_configs ||= ::Apps::AccountConfig.where(account_id: account_ids)
      end

      def device_configs
        device_ids = account.all_descendant_devices.pluck(:id)
        @device_configs ||= ::Apps::DeviceConfig.where(device_id: device_ids)
      end

      def custom_configs
        account_ids = accounts.pluck(:id)
        @custom_configs ||= ::Apps::CustomConfig.where(account_id: account_ids).to_a
      end

      def whitelists
        account_whitelists + device_whitelists + custom_whitelists
      end

      def account_whitelists
        [].tap do |a|
          account_configs.each do |account_config|
            acct = account_config.account
            app  = account_config.app
            app_whitelist_config(app)&.each do |whitelist_type, paths|
              config_keys = paths.dig(:config_path)
              account_whitelist = account_config.config.dig(*config_keys)
              account_whitelist&.each do |entry|
                a << build_whitelist_entry(account_config, acct, nil, app, whitelist_type, entry)
              end
            end
          end
        end
      end

      def device_whitelists
        [].tap do |a|
          device_configs.each do |device_config|
            device = device_config.device
            acct   = device.account
            app    = device_config.app
            app_whitelist_config(app)&.each do |whitelist_type, paths|
              config_keys = paths.dig(:config_path)
              account_whitelist = device_config.config.dig(*config_keys)
              account_whitelist&.each do |entry|
                a << build_whitelist_entry(device_config, acct, device, app, whitelist_type, entry)
              end
            end
          end
        end
      end

      def custom_whitelists
        [].tap do |a|
          custom_configs.each do |custom_config|
            acct = custom_config.account
            app  = custom_config.app
            (custom_config&.config&.dig("list") || []).each do |entry|
              type  = entry.first[0]
              value = entry.first[1]
              a << build_whitelist_entry(custom_config, acct, nil, app, type, value)
            end
          end
        end
      end

      def app_whitelist_config(app)
        APP_WHITELISTS.dig(app.configuration_type)
      end

      def build_whitelist_entry(config, acct, device, app, type, entry)
        OpenStruct.new(
          config:  config,
          account: acct,
          device:  device,
          app:     app,
          type:    type,
          entry:   entry
        )
      end
    end
  end
end
