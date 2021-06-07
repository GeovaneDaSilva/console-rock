module Hunts
  # Condition for event log category
  class EventLogCategoryCondition < Condition
    validates :condition, presence: true
    validates :operator, inclusion: { in: %w[is_equal_to] }
  end
end
