module Hunts
  # event from source test
  class EventFromSourceTest < Test
    validates :conditions, length: { is: 3 }, unless: :script_override?

    def build_conditions
      existing_conditions = conditions.pluck(:type)

      %w[
        Hunts::EventLogNameCondition Hunts::EventLogSourceCondition Hunts::LikeCondition
      ].each.with_index do |condition_type, i|
        next if existing_conditions.include?(condition_type)

        conditions.new(type: condition_type, operator: :is_equal_to, order: i + 1)
      end
    end
  end
end
