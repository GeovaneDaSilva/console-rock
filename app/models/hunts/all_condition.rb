module Hunts
  # All possible conditions
  class AllCondition < Condition
    validates :condition, presence: true,
                          unless:   proc { |c| %w[exists does_not_exist].include?(c.operator) }
    validates :operator, presence: true
  end
end
