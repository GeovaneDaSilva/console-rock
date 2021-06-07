module Accounts
  # Get recent hunt results within period
  class RecentHuntResult
    include HuntResultable

    def initialize(account)
      @account = account
    end

    private

    def hunt_results
      @hunt_results ||= @account.all_descendant_hunt_results.unarchived
    end
  end
end
