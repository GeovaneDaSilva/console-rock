module Devices
  module Apps
    # Configure app
    class ConfigsController < AuthenticatedController
      include Configable

      def update
        authorize device.customer, :can_manage_apps?

        if app_config.update(config: cast_value(config_params))
          broadcast_app_check!

          flash[:notice] = "Updated configuration of the #{app.title} App \
                            for #{device.hostname} successfully"
        else
          flash[:error] = "Unable up update configuration of the #{app.title} App \
                          for #{device.hostname}  failed"
        end

        redirect_to device_path(device, anchor: "apps")
      end

      def destroy
        authorize device.customer, :can_manage_apps?

        if app_config.destroy
          broadcast_app_check!
          flash[:notice] = "Removal of configuration of the #{app.title} App \
                            for #{device.hostname} successful"
        else
          flash[:error] = "Removal configuration of the #{app.title} App \
                          for #{device.hostname} failed"
        end

        redirect_to device_path(device, anchor: "apps")
      end

      private

      def device
        @device ||= Device.find(params[:device_id])
      end

      def app
        @app ||= App.find(params[:app_id])
      end

      def app_config
        @app_config ||= device.app_configs.find_or_initialize_by(app: app)
      end

      def broadcast_app_check!
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Device", device.id,
          { type: "app_config_update", payload: { app_id: app.id } }.to_json
        )
      end

      def config_params
        ::Apps::Configs::Base.new(params.permit!).merge(
          params[:config].permit!.to_h
        )
      end
    end
  end
end
