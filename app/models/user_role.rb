# Connect a user to a rolable object with a given role
class UserRole < ApplicationRecord
  audited
  # The number is meaningless, feel free to fill in the gaps.
  # Originally, the accounts were to be ordered as supersets of permissions, with each higher number having
  # a subset of the permissions of the role above it.  If you find code that reflects that thinking,
  # TELL SOMEONE IMMEDIATELY.
  enum role: {
    owner:               0,
    billing:             4,
    incident_responder:  9,
    viewer:              10,
    report_viewer:       11,
    distributor_billing: 12
  }

  belongs_to :user, touch: true
  belongs_to :account, touch: true

  validates :user_id, uniqueness: { scope: [:account_id] }
  validate :at_least_one_owner

  private

  def at_least_one_owner
    return unless role_changed?

    errors.add(:role, "must have at least one owner") if currently_owner? && no_other_owner_roles?
  end

  def no_other_owner_roles?
    account.root? && account.user_roles.owner.where.not(id: id).none?
  end

  def currently_owner?
    account && account.user_roles.owner.where(id: id).any?
  end
end
