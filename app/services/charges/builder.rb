module Charges
  # Entry point for creating a new charge
  # Creates charge and appropriate line items
  # Account should be provider with a plan
  class Builder
    def initialize(account, start_date, end_date)
      @account = account
      @plan = account.plan
      @start_date = start_date
      @end_date = end_date
      @all_sub_items = @plan.plan_type == "pax8"
    end

    def call
      return if pax8_sub_account

      ActiveRecord::Base.transaction do
        add_line_items!

        charge.update(amount: charge.line_items.sum(&:amount))
      end

      charge
    end

    private

    def charge
      @charge ||= @account.charges.create(start_date: @start_date, end_date: @end_date, plan: @plan)
    end

    def add_line_items!
      charge.line_items.new(item_type: :plan_base, amount: @plan.price_per_frequency).tap do |line_item|
        line_item.meta_for_plan_base!(@account, @plan)
        line_item.save
      end

      add_plan_line_items!

      # %i[office_365_mailbox firewall].each do |line_item_type|
      # This is a hack when we suddenly changed billing to ignore distinctions between device and firewall,
      # but still not bill for O365 mailboxes.  In reality, this billing setup no longer reflects our
      # business policy and should be reworked.
      %i[firewall].each do |line_item_type|
        add_billable_instance_line_items!(line_item_type)
      end
    end

    def add_plan_line_items!
      plan_devices = ActiveDeviceFinder.new(@account, @start_date, @end_date, @all_sub_items).call
      app_meta = {
        account_id: @account.account.id, account_name: @account.account.name
      }

      included_count = 0
      plan_devices.find_each do |device|
        charge.line_items.new(item_type: :plan_base_device).tap do |line_item|
          line_item.amount = @plan.price_for_device(included_count)
          line_item.meta_for_device!(device, @start_date, @end_date, app_meta)
          line_item.save
        end

        included_count += 1
      end
      @device_count = included_count
    end

    def add_billable_instance_line_items!(line_item_type)
      plan_mailboxes = ActiveBillableInstanceFinder.new(
        @account, line_item_type, @start_date, @end_date, @all_sub_items
      ).call

      included_count = line_item_type == :office_365_mailbox ? 0 : @device_count
      plan_mailboxes.each do |mailbox|
        next if mailbox.details.dig("type") == "unknown"

        charge.line_items.new(item_type: line_item_type).tap do |line_item|
          # line_item.amount = @plan.send("price_for_#{line_item_type}", included_count)
          # As above, sudden change to bill firewalls as devices.
          line_item.amount = @plan.price_for_device(included_count)
          line_item.send("meta_for_#{line_item_type}!", mailbox, @start_date, @end_date)
          line_item.save
        end

        included_count += 1
      end
    end

    def pax8_sub_account
      @plan.plan_type == "pax8" && @account != @account.root ? true : false
    end
  end
end
