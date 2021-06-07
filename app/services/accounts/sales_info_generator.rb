# :nodoc
module Accounts
  # Generates information details pertaining to accounts
  class SalesInfoGenerator
    def stale_info
      past_due_seven_days = billing_accounts.actionable_past_due
      {
        with_no_devices:                       billing_accounts.collect do |a|
                                                 a if a.all_descendant_devices.blank?
                                               end.compact,
        past_due_payment_for_seven_days:       past_due_seven_days,
        past_due_payment_for_seven_days_trial: past_due_seven_days.all_trials,
        used_to_have_more_than_four_devices:   accounts_used_to_have_more_devices
      }
    end

    def general_info
      {
        trial:         billing_accounts.all_trials,
        current:       billing_accounts.current,
        trial_expired: billing_accounts.trial_expired,
        past_due:      billing_accounts.past_due,
        billing_info:  billing_information
      }
    end

    private

    def billing_accounts
      @billing_accounts ||= Account.with_plan
    end

    def accounts_used_to_have_more_devices
      result = []
      billing_accounts.each do |a|
        current_device_count = a.all_descendant_devices.size
        next if current_device_count >= 5

        a_ids = a.self_and_all_descendants.pluck(:id)

        last_month_device_count = Charge.where(account_id: a_ids,
                                               status:     :completed)
                                        .where("start_date BETWEEN ? AND ?",
                                               1.month.ago.beginning_of_month,
                                               1.month.ago.end_of_month)
                                        .joins(:line_items)
                                        .select("COUNT(line_items.id) AS count")[0]["count"]

        if last_month_device_count >= 5
          result << a
          next
        end
      end
      result
    end

    def billing_information
      results = {}
      billing_accounts.each do |a|
        id = a.billing_account.id

        results[id] ||= { all: 0, last_bill: nil, month_over_month: nil }

        charges = a.charges
        all = charges.completed.inject(0) { |sum, charge| sum + charge.amount_cents }
        results[id][:all] += all

        current_last_bill = results[id][:last_bill]

        results[id][:last_bill] = if (charges.last&.id || 0) > (current_last_bill&.id || 0)
                                    charges.last
                                  else
                                    current_last_bill
                                  end

        results[id][:month_over_month] ||= month_over_month(a)
      end
      results
    end

    def month_over_month(account)
      if account.id == 1
        # binding.remote_pry <-- TODO: THIS GOT HIT 6 TIMES IN ONE LOAD
      end
      result = { account.id => [] }
      account_ids = account.self_and_all_descendants.pluck :id

      3.downto(1) do |i|
        previous_month = charges_total(account_ids, (i + 1).months.ago)&.total_amount || 0
        current_month = charges_total(account_ids, i.months.ago)&.total_amount || 0
        percentage = previous_month.zero? ? 0 : ((current_month - previous_month) * 100 / previous_month)
        # result[account.id] = result[account.id].merge({ i.months.ago.strftime("%B %Y") => percentage })
        result[account.id] << percentage.to_s
      end
      result[account.id] = result[account.id].join("\t")
      result
    end

    def charges_total(account_ids, month)
      Charge.select("SUM(amount_cents) AS total_amount")
            .where(account_id: account_ids)
            .where("start_date BETWEEN ? AND ?",
                   month.beginning_of_month.strftime("%F %T"),
                   month.end_of_month.strftime("%F %T"))
            .group("id").first
    end
  end
end
