module Hunts
  # Browser visit tests
  class BrowserVisitTest < Test
    has_one :geocoded_threat, as: :threatable, dependent: :destroy

    validates :conditions, length: { is: 1 }, unless: :script_override?

    def build_conditions
      existing_conditions = conditions.pluck(:type)

      %w[Hunts::LikeCondition].each do |condition_type|
        next if existing_conditions.include?(condition_type)

        conditions.new(type: condition_type, operator: :is_equal_to)
      end
    end
  end
end
