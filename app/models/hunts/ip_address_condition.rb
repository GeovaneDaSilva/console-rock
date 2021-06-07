module Hunts
  # Condition for a test which is an IP address
  class IpAddressCondition < Condition
    validates :condition, presence: true
    validates :operator, inclusion: { in: %w[exists does_not_exist] }
  end
end
