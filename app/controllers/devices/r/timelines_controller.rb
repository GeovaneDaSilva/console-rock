module Devices
  module R
    # Breach timeline controller
    class TimelinesController < BaseController
      helper_method :device, :apps, :app_results, :ttps

      def show
        authorize device, :view_devices?

        @title = "#{device.hostname} Attack Timeline"

        respond_to do |format|
          format.html
          format.json
        end
      end

      private

      def ttps
        @ttps ||= TTP.find(app_results.ttp.collect { |app_result| app_result.details.ttp_id })
      end

      def app_results
        @app_results ||= ::Apps::DeviceResult.where(device_id: device.id)
                                             .order("detection_date DESC")
                                             .limit(200)
      end

      def apps
        @apps ||= if current_account.self_and_ancestors.where(beta_apps: true).any?
                    App.enabled.or(App.where(type: "Apps::DeviceApp", beta: true)).load
                  else
                    App.enabled.load
                  end
      end
    end
  end
end
