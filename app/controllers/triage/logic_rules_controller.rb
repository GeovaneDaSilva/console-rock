module Triage
  # Account level logic rule creation for app results
  class LogicRulesController < AuthenticatedController
    include Triagable
    include LogicRulable

    helper_method :account

    private

    def scope
      account
    end

    def app_results
      account.all_descendant_app_results
    end

    def account
      Account.find(params[:account_id])
    end

    def triage_path(opts = {})
      account_triage_path(account, opts.merge(app_id: app.id))
    end

    def logic_rule_path(opts = {})
      account_triage_logic_rule_path(account, opts)
    end
  end
end
