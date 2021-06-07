# Payment plans
# Columns explaination
#
# price_per_frequency: Price to charge on a recurring schedule
# frequency: Frequency to charge a fixed price (monthly, annually, etc)
# included_devices: Number of monitored devices for "free". Devices exceeding this # will be
#                        charged overages.
# price_per_device_overage: Amount per device to charge as an overage fee.
#
class Plan < ApplicationRecord
  include Flagable

  as_flag :subscribed_hooks, *Plans::SubscriptionChange::HOOK_MAP.keys.collect(&:to_sym)
  as_flag :unsubscribed_hooks, *Plans::SubscriptionChange::HOOK_MAP.keys.collect(&:to_sym)

  enum frequency: {
    one_time:    0,
    hourly:      3,
    daily:       5,
    monthly:     10,
    bi_annually: 15,
    annually:    20,
    three_year:  40
  }

  enum payment_plan: {
    pay_in_advance: 0,
    pay_at_end:     1
  }

  monetize :price_per_frequency_cents
  monetize :price_per_device_overage_cents
  monetize :price_per_office_365_mailbox_overage_cents
  monetize :price_per_firewall_overage_cents

  has_many :plan_apps, dependent: :destroy
  has_many :apps, through: :plan_apps

  has_many :accounts, dependent: :restrict_with_error
  has_many :charges, dependent: :restrict_with_error
  has_many :line_items, through: :charges

  validates :name, :frequency, :price_per_frequency, presence: true
  validate :unified_currency

  bitmask :on_demand_analysis_types, as: %i[
    file url
  ], zero_value: :none

  bitmask :on_demand_hunt_types, as: %i[
    processname url filename filehash
  ], zero_value: :none

  accepts_nested_attributes_for :plan_apps, allow_destroy: true

  scope :published, -> { where(published: true) }
  scope :managed, -> { where(managed: true) }

  def self.frequency_extension(frequency)
    case frequency
    when /one_time/
      100.years
    else
      Periodical.table(frequency)
    end
  end

  def revenue_per_month
    case frequency
    when /one_time/
      0
    when /hourly/
      price_per_frequency * 720
    when /daily/
      price_per_frequency * 30
    when /monthly/
      price_per_frequency
    when /bi_annually/
      price_per_frequency / 6
    when /annually/
      price_per_frequency / 12
    when /three_year/
      price_per_frequency / 36
    end
  end

  def human_frequency
    case frequency
    when /hourly/
      "hourly"
    when /one_time/
      "one time"
    when /daily/
      "day"
    when /monthly/
      "month"
    when /bi_annually/
      "every six months"
    when /annually/
      "year"
    when /three_year/
      "every three years"
    end
  end

  def minimum_charge
    price_per_frequency + (included_devices.to_i.zero? ? price_per_device_overage : 0)
  end

  # For the index of the device, give the price
  def price_for_device(count)
    count < included_devices.to_i ? 0 : price_per_device_overage
  end

  # For the index of the mailbox, give the price
  def price_for_office_365_mailbox(count)
    count < included_office_365_mailboxes.to_i ? 0 : price_per_office_365_mailbox_overage
  end

  # For the index of the firewall, give the price
  def price_for_firewall(count)
    count < included_firewalls.to_i ? 0 : price_per_firewall_overage
  end

  private

  # Validates that all the currency columns use the same currency
  def unified_currency
    currency_columns = self.class.attribute_names.select { |column| column.match(/_currency$/) }
    currency_values = currency_columns.collect { |column| send(column) }

    return unless currency_values.uniq.size > 1

    currency_columns.each do |column|
      errors.add(column.to_sym, "non-unified currencies")
    end
  end
end
