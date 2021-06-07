module Seed
  # Seed service for creating dummy EgressIp records for a given Customer
  class EgressIps
    def initialize(customer, amount:)
      @customer = customer
      @range = 1..amount
    end

    def call
      @range.each { |index| @customer.egress_ips.create self.class.random_attributes(index) }
    end

    def self.random_attributes(index)
      { ip: "10.10.10.#{index}" }.update(random_location)
    end

    def self.random_location
      [{ latitude: 43.5128737, longitude: -114.314008, city: "Hailey", state: "Idaho" },
       { latitude: 40.7058253, longitude: -74.1180844, city: "New York", state: "New York" },
       { latitude: 32.8208751, longitude: -96.8714209, city: "Dallas", state: "Texas" },
       { latitude: 55.7498598, longitude: 37.3523282, city: "Moscow", state: "Russia" }].sample
    end
  end
end
