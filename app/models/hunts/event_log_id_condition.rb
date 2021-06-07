module Hunts
  # Condition for event log with ID
  class EventLogIdCondition < Condition
    validates :condition, presence: true
    validates :operator, inclusion: { in: %w[is_equal_to] }
  end
end
