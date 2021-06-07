module Charges
  # Find Billable instances for account which were active during a given period
  class ActiveBillableInstanceFinder
    def initialize(account, line_item_type, start_date, end_date, all_non_trial = false)
      @account        = account
      @line_item_type = line_item_type
      @start_date     = start_date.beginning_of_day
      @end_date       = end_date.end_of_day
      @all_non_trial = all_non_trial
    end

    def call
      return [] if billable_instances.blank?

      billable_instances
        .active
        .select("DISTINCT ON (external_id) external_id, id, details, account_path, created_at")

      if @line_item_type.to_s == "office_365_mailbox"
        billable_instances.where(updated_at: @start_date..@end_date)
      else
        billable_instances
      end
    end

    private

    def billable_instances
      accounts = @all_non_trial ? all_non_trial_sub_account_paths : account_paths
      @billable_instances ||= BillableInstance.send(@line_item_type).where(account_path: accounts)
    end

    # This can be cheated by repeatedly destroying the entire account and remaking it to get
    # the first 7 days free...of course, everything in RC is subject to that cheat...
    def start_date
      billable_instances.order(:created_at).first.created_at
    end

    def account_paths
      @account.self_and_all_descendants.select do |account|
        account.billing_account == @account
      end.collect(&:path)
    end

    def all_non_trial_sub_account_paths
      @account.self_and_all_descendants.reject do |account|
        (account.billing_account.plan.trial || account.billing_account.plan.plan_type == "transition")
      end.collect(&:path)
    end
  end
end
