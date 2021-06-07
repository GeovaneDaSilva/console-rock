module Accounts
  module Apps
    module Whitelists
      # Account app incidents
      class RemovesController < AuthenticatedController
        def create
          authorize account, :manage_whitelists?

          if app_config.update(config: updated_config(updated_whitelist))
            flash[:notice] = "Whitelist entry removed"
          else
            flash[:error] = "Whitelist entry removal failed"
          end

          redirect_to account_apps_whitelists_path(account)
        end

        private

        def account
          @account ||= policy_scope(Account).find(params[:account_id])
        end

        def app
          @app ||= app_config.app
        end

        def app_config
          @app_config ||= ::Apps::Config.find(params[:config])
        end

        def app_whitelist_config
          APP_WHITELISTS.dig(app.configuration_type)
        end

        def whitelist(value)
          whitelist_path.reverse.reduce(value) do |key, val|
            Hash[val, key]
          end
        end

        def whitelist_path
          @whitelist_path ||= if app_config.type == "Apps::CustomConfig"
                                ["list"]
                              else
                                app_whitelist_config.dig(params[:type], :config_path)
                              end
        end

        def updated_whitelist
          current_whitelist = app_config.config.dig(*whitelist_path)
          if app_config.type == "Apps::CustomConfig"
            current_whitelist.reject do |item|
              item[params[:type]] == params[:entry]
            end
          else
            current_whitelist - Array(params[:entry])
          end
        end

        def updated_config(value)
          old_config = app_config.merged_config.with_indifferent_access
          old_config.deep_merge(whitelist(value)) { |_k, _original_val, new_val| new_val }
        end
      end
    end
  end
end
