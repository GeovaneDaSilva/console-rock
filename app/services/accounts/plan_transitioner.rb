module Accounts
  # transitions a account one (or no) plan to another
  class PlanTransitioner
    def initialize(account)
      @account = account
    end

    def call
      return if @account.plan.nil?

      disable_unavailable_apps!
    end

    private

    def disable_unavailable_apps!
      AccountApp.where(account: @account.self_and_all_descendants)
                .where.not(app: @account.plan.apps)
                .where.not(app: App.free)
                .where.not(app: App.discreet)
                .update(enabled_at: nil, disabled_at: nil)
    end
  end
end
