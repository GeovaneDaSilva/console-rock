module Hunts
  # Condition for a test based on Equality
  class EqualityCondition < Condition
    validates :condition, presence: true
    validates :operator, inclusion: { in: %w[is_equal_to is_not_equal_to] }
  end
end
