module Devices
  module Triage
    # Device level incident creation of app results
    class IncidentsController < AuthenticatedController
      include Triagable
      include Incidentable

      helper_method :device

      delegate :app_results, to: :device

      private

      def scope
        device
      end

      def device
        @device ||= Device.find(params[:device_id])
      end

      def app_counter_caches
        device.app_counter_caches.where(app: app)
      end

      def account
        device.customer
      end

      def triage_path(opts = {})
        device_triage_path(device, opts.merge(app_id: app.id))
      end

      def incident_path(opts = {})
        device_triage_incident_path(device, opts)
      end
    end
  end
end
