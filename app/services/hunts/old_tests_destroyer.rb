module Hunts
  # Destroy old revision hunt tests
  class OldTestsDestroyer
    def call
      Hunts::Test.joins(:hunt)
                 .where("hunts_tests.revision != hunts.revision")
                 .where("hunts_tests.updated_at < ?", 2.weeks.ago)
                 .find_each(&:destroy)
    end
  end
end
