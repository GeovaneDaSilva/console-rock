module Hunts
  # Condition for a test based on similarity
  class LikeCondition < Condition
    validates :condition, presence: true
    validates :operator, inclusion: {
      in: %w[is_equal_to is_not_equal_to starts_with ends_with contains does_not_contain]
    }
  end
end
