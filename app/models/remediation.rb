# :nodoc
class Remediation < ApplicationRecord
  include AttrJsonable

  attr_json_accessor :isolate

  belongs_to :result, class_name: "Apps::Result"
  belongs_to :remediation_plan

  enum status: {
    draft:       0,
    in_progress: 10,
    failed:      15,
    complete:    20
  }

  validates :result_id, presence: true
  validates :remediation_plan_id, presence: true

  scope :unresolved, -> { where.not("state = ?", 20) }
end
