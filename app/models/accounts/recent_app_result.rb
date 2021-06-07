module Accounts
  # Get recent app results within period
  class RecentAppResult
    include AppResultable

    def initialize(account)
      @account = account
    end

    private

    def app_results
      @account.all_descendant_app_results
    end
  end
end
