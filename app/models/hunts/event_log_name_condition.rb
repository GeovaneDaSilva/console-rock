module Hunts
  # Condition for event log names
  class EventLogNameCondition < Condition
    validates :condition, presence: true
    validates :operator, inclusion: { in: %w[is_equal_to] }
  end
end
