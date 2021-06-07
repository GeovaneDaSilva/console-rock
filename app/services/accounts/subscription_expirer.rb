module Accounts
  # Expire account subscriptions if actionable past due
  class SubscriptionExpirer
    def call
      Provider.where("paid_thru < ?", DateTime.current).active.find_each do |account|
        if account.billing_account.trial_expired?
          ServiceRunnerJob.perform_later("Accounts::AutomaticPlanTransitioner", account)
        else
          account.suspended!
          broadcast_check_for_work!(account)
        end
      end
    end

    private

    # Agents need to stop checking for hunts when actionable_past_due?
    # Send message to deactivate them
    def broadcast_check_for_work!(account)
      account.self_and_all_descendant_customers.each do |customer|
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
  end
end
