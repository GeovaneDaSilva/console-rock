# :nodoc
module BillingNotifiable
  extend ActiveSupport::Concern

  included do
    before_action :billing_warning
  end

  private

  def billing_warning
    return if current_provider.nil? || current_account.billing_account.current?

    billing_account = current_account.billing_account

    if billing_account.trial? && !billing_account.paid_thru?(3.days.from_now)
      trial_expiring_soon_notice
    elsif billing_account.trial_expired?
      trial_has_expired_notice
    elsif billing_account.past_due?
      past_due_notice
    end
  end

  def trial_expiring_soon_notice
    @payment_notice = {
      type:      "warning",
      link_text: "Subscribe Now",
      message:   "The trial for this account will expire soon. Add payment information to " \
                 "avoid service disruption."
    }
  end

  def trial_has_expired_notice
    @payment_notice = {
      type:      "error",
      link_text: "Subscribe Now",
      message:   "The trial for this account has expired. Agents will no longer execute some tasks."
    }
  end

  def past_due_notice
    @payment_notice = {
      type:      "error",
      link_text: "Update Payment Method",
      message:   "This account is past due. Agents will no longer execute some tasks."
    }
  end
end
