module Devices
  # Render Account stats as a JSON string
  class StatsToJson
    include DeviceStatsable
    attr_reader :device

    def initialize(device)
      @device = device
    end

    def call
      AuthenticatedController.renderer.render(
        template: "shared/device_stats", format: :json,
        assigns: {
          device: @device, totals: totals, historical_counts: historical_counts
        }
      )
    end
  end
end
