module Devices
  module R
    # Breach report for a device
    class BreachesController < BaseController
      include Pagy::Backend
      include DeviceStatsable

      helper_method :device, :apps, :all_app_results, :totals, :ttps, :hunt_results

      def show
        authorize device, :view_devices?

        @title = "#{device.hostname} Breach Report"

        @graph_json = Devices::StatsToJson.new(device).call
      end

      private

      def hunt_results
        @hunt_results ||= HuntResult.unarchived
                                    .positive
                                    .includes(:hunt)
                                    .where(device_id: device.id)
      end

      def apps
        @apps ||= App.all
      end

      def all_app_results
        @all_app_results ||= ::Apps::DeviceResult.where(device: device)
                                                 .order("detection_date DESC")
      end

      def ttps
        @ttps ||= TTP.find(ttp_ids)
      end

      def ttp_ids
        apps.where(report_template: :ttp).collect do |app|
          app.device_results
             .where(device: device)
             .order("detection_date DESC")
             .page(params["app_#{app.id}".to_sym])
             .collect(&:details)
             .collect(&:ttp_id)
        end.flatten.uniq.reject(&:blank?)
      end
    end
  end
end
