module Devices
  module Triage
    # Device level whitelisting of app results
    class WhitelistsController < AuthenticatedController
      include Triagable
      include Whitelistable

      helper_method :device

      delegate :app_results, to: :device

      private

      def scope
        device
      end

      def device
        @device ||= Device.find(params[:device_id])
      end

      def triage_path(*opts)
        device_triage_path(device, *opts)
      end

      def whitelist_path(*opts)
        device_triage_whitelist_path(device, *opts)
      end

      def account
        device.account
      end
    end
  end
end
