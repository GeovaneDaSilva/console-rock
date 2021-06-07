module Devices
  # Get recent app results within a period
  class RecentAppResult
    include AppResultable

    def initialize(device)
      @device = device
    end

    private

    def app_results
      @app_results ||= @device.app_results
    end
  end
end
