module Hunts
  # Yara tests
  class YaraTest < Test
    validates :conditions, length: { is: 2 }

    def build_conditions
      existing_conditions = conditions.pluck(:type)

      %w[Hunts::EqualityCondition Hunts::YaraUploadCondition].each.with_index do |condition_type, i|
        next if existing_conditions.include?(condition_type)

        conditions.new(type: condition_type, operator: :is_equal_to, order: i + 1)
      end
    end
  end
end
