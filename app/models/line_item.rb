# A line item for a charge
class LineItem < ApplicationRecord
  monetize :amount_cents

  enum item_type: {
    plan_base:             0,
    plan_base_device:      1,
    additional_app_device: 2,
    office_365_mailbox:    3,
    firewall:              4
  }

  scope :device, lambda {
    where(item_type: [item_types["plan_base_device"], item_types["additional_app_device"]])
  }

  scope :gratis, -> { where(amount_cents: 0) }
  scope :non_gratis, -> { where("amount_cents > ?", 0) }

  belongs_to :charge

  def meta_for_plan_base!(account, plan)
    self.meta = {
      id:               plan.id,
      name:             plan.name,
      base_price:       plan.price_per_frequency,
      price_per_device: plan.price_per_device_overage,
      included_devices: plan.included_devices,
      account_id:       account.id,
      account_name:     account.name.to_s.force_encoding("UTF-8")
    }
  end

  def meta_for_device!(device, start_date, end_date, additional_meta = {})
    self.meta = {
      id:            device.id,             hostname:    device.hostname,
      mac_address:   device.mac_address,    customer_id: device.customer_id,
      customer_name:  device.customer.name.to_s.force_encoding("UTF-8"),
      billing_account_name: device.customer.billing_account.name.to_s.force_encoding("UTF-8"),
      billing_account_id: device.customer.billing_account.id,
      connected_for: device.connectivity_logs.where(connected_at: start_date..end_date).sum(:duration)
    }.merge(additional_meta)
  end

  def meta_for_office_365_mailbox!(office_365_mailbox, _start_date, _end_date)
    self.meta = {
      external_id:          office_365_mailbox.external_id,
      account_name:         office_365_mailbox.account.name.to_s.force_encoding("UTF-8"),
      account_id:           office_365_mailbox.account.id,
      billing_account_name: office_365_mailbox.account.billing_account.name.to_s.force_encoding("UTF-8"),
      billing_account_id:   office_365_mailbox.account.account.billing_account.id
    }.merge(office_365_mailbox.details)
  end

  def meta_for_firewall!(firewall, _start_date, _end_date)
    self.meta = {
      external_id: firewall.external_id,
      account_name: firewall.account.name.to_s.force_encoding("UTF-8"), account_id: firewall.account.id,
      billing_account_name: firewall.account.billing_account.name.to_s.force_encoding("UTF-8"),
      billing_account_id:   firewall.account.account.billing_account.id
    }.merge(firewall.details)
  end
end
