# TTP descriptors
class TTP < ApplicationRecord
  has_many :hunt_test_results, class_name: "Hunts::TestResult", dependent: :nullify
  has_many :hunt_results, through: :hunt_test_results

  validates :id, :tactic, :technique, :description, presence: true

  def id=(val)
    super(val.parameterize.upcase)
  end
end
