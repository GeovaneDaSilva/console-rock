module Hunts
  # Condition for a test a service's state
  class ServiceStateCondition < Condition
    validates :condition, presence: true, inclusion: { in: %w[running stopped any paused] }
    validates :operator, inclusion: { in: %w[is_equal_to] }

    def condition=(condition)
      super(condition.downcase)
    end
  end
end
