module Devices
  module Triage
    # Device level logic rule creation for app results
    class LogicRulesController < AuthenticatedController
      include Triagable
      include LogicRulable

      helper_method :device, :account

      private

      def scope
        device
      end

      def device
        @device ||= Device.find(params[:device_id])
      end

      def account
        device.customer
      end

      def app_results
        device.app_results.includes(:customer).where(incident_id: nil)
      end

      def triage_path(opts = {})
        device_triage_path(device, *opts)
      end

      def logic_rule_path(opts = {})
        device_triage_logic_rule_path(device, opts)
      end
    end
  end
end
