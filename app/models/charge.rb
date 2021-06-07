# Record of a charge for a plan
class Charge < ApplicationRecord
  enum status: {
    processing: 0,
    completed:  10,
    failed:     20,
    skipped:    30
  }

  monetize :amount_cents

  belongs_to :plan
  belongs_to :account, touch: true

  has_many :uploads, as: :sourceable
  has_many :line_items, autosave: true, dependent: :restrict_with_error
end
