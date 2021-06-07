module Charges
  # Find devices for account which were active during a given period
  class ActiveDeviceFinder
    def initialize(account, start_date, end_date, all_sub_accounts = false)
      @account    = account
      @start_date = start_date.beginning_of_day
      @end_date   = end_date.end_of_day
      @all_sub_accounts = all_sub_accounts
    end

    def call
      customers = @all_sub_accounts ? all_non_trial_customer_ids : customer_ids
      Device.where(customer: customers)
            .joins(:connectivity_logs)
            .where(devices_connectivity_logs: { connected_at: @start_date..@end_date })
            .distinct
    end

    def customer_ids
      @customer_ids ||= @account.self_and_all_descendant_customers.select do |customer|
        customer.billing_account == @account
      end
    end

    def all_non_trial_customer_ids
      @account.self_and_all_descendant_customers.reject do |customer|
        (customer.billing_account.plan.trial? || customer.billing_account.plan.plan_type == "transition")
      end
    end
  end
end
