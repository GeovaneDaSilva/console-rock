module Administration
  module Apps
    # Notifies all devices of app updates
    class NotifiesController < Administration::BaseController
      def create
        authorize :administration, :notify_devices_of_app_update?

        Rails.cache.write("app-update-notification", 0, expires_in: 1.hour)
        ServiceRunnerJob.set(queue: :utility).perform_later("Devices::UpdateApps")

        flash[:notice] = "Broadcasting app update message to all devices"

        redirect_to administration_apps_path
      end
    end
  end
end
