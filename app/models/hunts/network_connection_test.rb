module Hunts
  # Network connection tests
  class NetworkConnectionTest < Test
    validates :conditions, length: { is: 1 }, unless: :script_override?

    def build_conditions
      existing_conditions = conditions.pluck(:type)

      %w[Hunts::IpAddressCondition].each do |condition_type|
        next if existing_conditions.include?(condition_type)

        conditions.new(type: condition_type, operator: :exists)
      end
    end
  end
end
