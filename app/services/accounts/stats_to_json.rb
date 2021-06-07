module Accounts
  # Render Account stats as a JSON string
  class StatsToJson
    include AccountStatsable
    attr_reader :account

    def initialize(account)
      @account = account
    end

    def call
      AuthenticatedController.renderer.render(
        template: "shared/account_stats", format: :json,
        assigns: {
          account: @account, totals: totals, historical_counts: historical_counts
        }
      )
    end
  end
end
