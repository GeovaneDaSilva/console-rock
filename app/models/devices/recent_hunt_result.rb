module Devices
  # Get recent hunt results within period
  class RecentHuntResult
    include HuntResultable

    def initialize(device)
      @device = device
    end

    private

    def hunt_results
      @hunt_results ||= HuntResult.unarchived.where(device: @device)
    end
  end
end
