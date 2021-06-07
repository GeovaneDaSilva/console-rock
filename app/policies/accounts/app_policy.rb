module Accounts
  # App policy where related to accounts
  class AppPolicy < Accounts::ApplicationPolicy
    alias app record

    def whitelistable?
      APP_WHITELISTS[app.configuration_type].present?
    end

    def runnable?
      return false if app.disabled?
      return false unless enabled_account_app

      return true if billing_account.trial?
      return true if app.free?

      return false if billing_account.actionable_past_due?

      true
    end

    def can_enable?
      return false if app.disabled?
      return false if inherited?

      return true if app.free?
      return true if billing_account.trial?
      return true if billing_account.subscribed? && plan.apps.include?(app)

      false
    end

    def inherited?
      enabled_account_app && enabled_account_app.account != account
    end

    private

    def enabled_account_app
      AccountApp.where(account: account.self_and_ancestors, app: app)
                .where(disabled_at: nil)
                .where.not(enabled_at: nil)
                .order(account_id: :asc)
                .first
    end
  end
end
