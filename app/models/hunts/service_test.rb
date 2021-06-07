module Hunts
  # Service tests
  class ServiceTest < Test
    validates :conditions, length: { is: 2 }, unless: :script_override?

    def build_conditions
      existing_conditions = conditions.pluck(:type)

      %w[Hunts::LikeCondition Hunts::ServiceStateCondition].each.with_index do |condition_type, i|
        next if existing_conditions.include?(condition_type)

        conditions.new(type: condition_type, operator: :is_equal_to, order: i + 1)
      end
    end
  end
end
