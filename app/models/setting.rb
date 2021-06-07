# A provider's settings
class Setting < ApplicationRecord
  belongs_to :account, touch: true

  enum verbosity: {
    trace:   0,
    debug:   1,
    info:    2,
    warning: 3,
    error:   4,
    fatal:   5
  }

  enum channel: {
    stable: 0,
    beta:   1
  }, _prefix: true

  validates :polling, numericality: { greater_than_or_equal_to: 1 }
  validates :user_session_timeout, numericality: { greater_than_or_equal_to: 1 }, allow_blank: true
  validates :max_cpu_usage, numericality: { greater_than: 1, less_than_or_equal_to: 100 }
  validates :full_disk_scan_time, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
  validates :max_memory_usage, numericality: { greater_than_or_equal_to: 75_000_000 }
  validates :max_sustained_memory_usage, numericality: { greater_than_or_equal_to: 300 }
  validates :device_expiration, numericality: { greater_than_or_equal_to: 1 }, allow_blank: true

  scope :two_factor_accounts, -> { where("two_factors @> ?", { accounts: "true" }.to_json) }
  scope :two_factor_sub_accounts, -> { where("two_factors @> ?", { sub_accounts: "true" }.to_json) }

  def setting_fields
    attributes.reject { |k, _v| %w[id account_id created_at license_key].include?(k) }
  end

  def admin_config
    if account.root?
      super.to_h
    else
      account&.parent&.setting&.admin_config.to_h.merge(super.to_h)
    end
  end

  def admin_config=(val)
    super val.to_h.reject { |_k, v| v == "_destroy" }
  end

  def broadcast_changes!
    account.self_and_all_descendant_customers.find_each do |customer|
      ServiceRunnerJob.perform_later(
        "DeviceBroadcasts::Customer", customer, { type: "config" }.to_json
      )
    end
  end
end
