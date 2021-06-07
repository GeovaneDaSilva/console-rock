module Accounts
  # Change a account's plan
  class PlansController < AuthenticatedController
    def create
      authorize account, :can_modify_plan?
      old_plan = account.plan
      paid_thru = account.billing_account.paid_thru

      if plan.trial? && !old_plan.nil?
        flash[:error] = "Cannot change from paid plan to trial"

        redirect_to account_path(account, anchor: "billing")
      elsif account.update(plan: plan, status: :active, paid_thru: paid_thru)
        Plans::SubscriptionChange.new(account, old_plan).call
        transition_plan!

        flash[:notice] = "Successfully subscribed to plan"

        if account.valid_credit_card?
          redirect_to account_path(account, anchor: "billing")
        else
          redirect_to new_account_credit_card_path(account)
        end
      else
        flash[:error] = "Unable to subscribe to plan"

        redirect_to account_path(account, anchor: "billing")
      end
    end

    def destroy
      authorize account, :can_modify_plan?

      if account.update(status: :canceled)
        flash[:notice] = "Successfully canceled subscription"
      else
        flash[:error] = "Unable to cancel subscription"
      end

      redirect_to account_path(account, anchor: "billing")
    end

    # un-cancel plan
    def update
      authorize account, :can_reactivate_plan?

      if account.update(status: :active)
        Charges::Charger.new(account, account.plan).call if account.chargeable?
        flash[:notice] = "Subscription reactivated"
      else
        flash[:error] = "Unable to reactivate subscription"
      end

      redirect_to account_path(account, anchor: "billing")
    end

    private

    def transition_plan!
      Accounts::PlanTransitioner.new(account).call
      Charges::Charger.new(account, account.plan).call if account.chargeable?
    end

    def account
      @account ||= Account.find(params[:account_id])
    end

    def plan
      @plan ||= policy_scope(Plan).find(params[:plan_id])
    end

    def skip_credit_card_required?
      true
    end
  end
end
