module Charges
  # Charges a account
  class Charger
    def initialize(account, plan, force_charge_now = false)
      @account          = account
      @plan             = plan
      @force_charge_now = force_charge_now
    end

    def call
      return @account unless @account.reload.chargeable? || @force_charge_now

      if charge.nil?
        pax8_update if @plan.plan_type == "pax8"
        return
      end

      if charge.amount.to_f > 1.0 && @account.created_at < 30.days.ago
        charge_account!
      else
        skip_charge!
      end

      @account
    end

    private

    def new_paid_thru_date
      [Date.current, @account.paid_thru].max + Plan.frequency_extension(@plan.frequency)
    end

    def charge_attributes(charge, status)
      {
        plan:                     @plan,
        status:                   status,
        braintree_transaction_id: charge&.transaction&.id,
        card_masked_number:       charge&.transaction&.credit_card_details&.masked_number,
        card_type:                charge&.transaction&.credit_card_details&.card_type
      }
    end

    def charge_account!
      if %w[pax8 barracudamsp].include?(@plan.plan_type)
        send_invoice!
      else
        charge_result = charge_card!
        charge_result.success? ? successful_charge!(charge_result) : failed_charge!(charge_result)
      end
    end

    def send_invoice!
      update_account_status
      Accounts::PaymentMailer.send_invoice(@account, charge).deliver_later
    end

    def charge_card!
      Braintree::Transaction.sale(
        amount:               charge.amount.to_f,
        customer_id:          @account.id,
        payment_method_token: @account.card_payment_method_token,
        options:              {
          submit_for_settlement: true
        }
      )
    end

    # When the charge_amount == 0, skip the charging and increment the paid_thru_date
    def skip_charge!
      return if @plan.trial

      charge.update(status: :skipped)
      @account.update(paid_thru: new_paid_thru_date)
    end

    def update_account_status
      was_actionable_past_due = @account.actionable_past_due?
      @account.update(paid_thru: new_paid_thru_date)
      pax8_update(charge) if @plan.plan_type == "pax8"
      broadcast_check_for_hunts! if was_actionable_past_due
      broadcast_check_for_apps! if was_actionable_past_due
      update_other_applications(true)
    end

    def successful_charge!(charge_result)
      charge.update(charge_attributes(charge_result, :completed))
      update_account_status
      Accounts::PaymentMailer.successful_payment(@account, charge).deliver_later
      Accounts::AutomaticPlanTransitioner.new(@account).call if @plan.plan_type == "transition"
    end

    def pax8_update(charge = nil)
      if @account == @account.root
        update_all_non_trial_sub_accounts
        charge.update(status: :completed)
      else
        @account.update(paid_thru: @account.root.paid_thru)
      end
    end

    def update_all_non_trial_sub_accounts
      @account.all_descendants.where(plan_id: @plan.id).where.not(status: %i[suspended canceled])
              .update_all(paid_thru: @account.paid_thru)
    end

    def failed_charge!(charge_result)
      Rails.logger.tagged("PaymentError") do
        Rails.logger.fatal(
          "Unable to create charge for Account #{@account.name}:#{@account.id} \
          #{charge_result.message}"
        )
      end
      charge.update(charge_attributes(charge_result, :failed))

      return unless sequential_charge_failure_count >= 5

      @account.update(status: :suspended)
      Accounts::PaymentMailer.unable_to_charge(@account).deliver_later
      update_other_applications(false)
    end

    def sequential_charge_failure_count
      @account.charges.order("created_at DESC").limit(5)
              .pluck(:status)
              .take_while { |status| status == "failed" }
              .length
    end

    def charge
      @charge ||= Charges::Builder.new(@account, start_date, end_date).call
    end

    def start_date
      @start_date ||= (@account.last_charge_end_date + 1.second).to_datetime
    end

    def end_date
      @end_date ||= DateTime.current.to_datetime
    end

    # Agents have stopped checking for new hunts when actionable_past_due?
    # Send message to re-activate them
    def broadcast_check_for_hunts!
      @account.self_and_all_descendant_customers.find_each do |customer|
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Customer",
          customer,
          { type: "hunts", payload: {} }.to_json
        )
      end
    end

    # Agents have stopped checking for new apps when actionable_past_due?
    # Send message to re-activate them
    def broadcast_check_for_apps!
      @account.self_and_all_descendant_customers.find_each do |customer|
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Customer",
          customer,
          { type: "apps", payload: {} }.to_json
        )
      end
    end

    # Other applications (app result analysis, database saver, integration polling, etc.) need to update
    # the billing status of this account and its descendants.
    def update_other_applications(paid)
      ServiceRunnerJob.perform_later("OtherApps::UpdateBillingStatus", @account, paid)
    end
  end
end
