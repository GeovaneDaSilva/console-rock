# :nodoc
class RemediationPlan < ApplicationRecord
  belongs_to :incident, class_name: "Apps::Incident"
  belongs_to :account

  has_many :remediations, dependent: :destroy

  validates :account_path, presence: true
end
