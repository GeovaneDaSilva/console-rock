module Charges
  # Finds AccountApp records which are active for a plan
  # Includes AccountApps which are currently active
  # Includes AccountApps which where disabled within the time period
  # Excludes AccountApps which have apps belonging to the plan
  class ActiveAccountAppFinder
    def initialize(account, plan, start_date, end_date)
      @account    = account
      @plan       = plan
      @start_date = start_date
      @end_date   = end_date
    end

    def call
      AccountApp.joins(:app)
                .where(id: account_apps)
                .where.not(apps: { id: @plan.apps, disabled: true })
    end

    def account_apps
      AccountApp.where(id: active_account_apps)
                .or(AccountApp.where(id: disabled_account_apps))
    end

    def active_account_apps
      AccountApp.where(account: @account.self_and_all_descendants)
                .where("enabled_at <= ?", @end_date)
                .where(disabled_at: nil)
    end

    def disabled_account_apps
      AccountApp.where(account: @account.self_and_all_descendants)
                .where("enabled_at <= ?", @end_date)
                .where(disabled_at: @start_date..@end_date)
    end
  end
end
