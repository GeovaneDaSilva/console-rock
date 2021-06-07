# :nodoc
class HuntPolicy < ApplicationPolicy
  def edit?
    incident_responder? && !record.feed?
  end

  def run_manually?
    editor?
  end

  def destroy?
    incident_responder?
  end

  def runnable?
    return true if billing_account.trial?

    return false if billing_account.trial_expired?
    return false if billing_account.actionable_past_due?

    return true if record.on_demand && billing_account.plan.threat_hunting?
    return false if record.feed && !billing_account.plan.threat_intel_feeds?

    billing_account.plan.threat_hunting?
  end

  private

  def role_accounts
    record.group.account.self_and_ancestors
  end

  def root
    @root ||= record.group.account.root
  end

  def billing_account
    @billing_account ||= record.group.account.billing_account
  end
end
