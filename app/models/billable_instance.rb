# Track activity for elements which might not have a direct
# DB record
class BillableInstance < ApplicationRecord
  include AttrJsonable

  attr_json_accessor :details, :mfa_status

  enum line_item_type: {
    office_365_mailbox:    0,
    firewall:              1,
    office_365_assessment: 2,
    sentinelone:           3
  }

  scope :active_within_month, -> { where(updated_at: 1.month.ago..DateTime.current) }
  scope :active, -> { where(active: true) }

  after_commit :touch_accounts

  def account
    @account ||= Account.where(path: account_path).first
  end

  private

  def touch_accounts
    return if account_path.blank?

    Account.with_advisory_lock("account-touch/#{account_path.split('.').first}") do
      Account.where("path @> ?", account_path).update_all(updated_at: DateTime.current)
    end
  end
end
