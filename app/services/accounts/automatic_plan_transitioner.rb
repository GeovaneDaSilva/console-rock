module Accounts
  # handles situations where upon the end of one plan (e.g. a trial), the account should automatically
  # move along a predetermined path
  class AutomaticPlanTransitioner
    def initialize(account)
      @account = account
      @old_plan = account&.plan
    end

    # This only gets called if the plan is expired
    def call
      return if @account.nil?

      target = PlanTransition.find_by(from_plan: @old_plan&.id)&.to_plan
      if target.nil?
        @account.trial_expired!
        broadcast_check_for_work!
      else
        @account.update(plan_id: target) ? transition_plan! : error_message(target)
      end
    end

    private

    def broadcast_check_for_work!
      @account.self_and_all_descendant_customers.each do |customer|
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Customer",
          customer,
          { type: "hunts", payload: {} }.to_json
        )

        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Customer",
          customer,
          { type: "apps", payload: {} }.to_json
        )
      end
    end

    def transition_plan!
      Plans::SubscriptionChange.new(@account, @old_plan).call
      Accounts::PlanTransitioner.new(@account).call
      Charges::Charger.new(@account, @account.plan).call if @account.chargeable?
    end

    def error_message(target)
      raise ::StandardError, "Failure to auto-transition #{@account} from #{@old_plan&.id} to #{target}"
    end
  end
end
