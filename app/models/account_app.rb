# Reference model
class AccountApp < ApplicationRecord
  belongs_to :account
  belongs_to :app

  scope :enabled, -> { where(disabled_at: nil).where.not(enabled_at: nil) }
  scope :disabled, -> { where.not(disabled_at: nil) }
  scope :not_enabled, -> { where(enabled_at: nil) }

  def enabled?
    enabled_at.present? && disabled_at.blank?
  end

  def disabled?
    !enabled?
  end
end
