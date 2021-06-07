module Api
  module V1
    module Devices
      # Device Apps
      class AppsController < Api::V1::Devices::DevicesBaseController
        helper_method :all_account_apps, :account_app, :apps, :app_config

        def index; end

        def show
          respond_to do |format|
            format.json
            format.lua do
              send_data(lua_script, type: "text/plain", filename: "#{account_app.id}.lua")
            end
          end
        end

        private

        def account_app
          @account_app ||= all_account_apps.find(params[:id])
        end

        def all_account_apps
          @all_account_apps ||= AccountApp.where(
            account: device.customer.self_and_all_ancestors
          )
        end

        def apps
          @apps ||= ::Apps::DeviceApp
                    .joins(:accounts)
                    .where(accounts: { id: device.customer.self_and_all_ancestors })
                    .distinct
                    .page(params[:page]).per(50)
        end

        def app_config
          device.app_config_for_app(account_app.app)&.merged_config
        end

        def lua_script
          ApplicationController.renderer.render(
            "api/v1/devices/apps/show.lua", locals: { account_app: account_app, app_config: app_config },
                                            format: :lua
          )
        end
      end
    end
  end
end
