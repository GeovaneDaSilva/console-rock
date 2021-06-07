module Seed
  # Service to setup a demo for a given Provider
  class Provider
    def initialize(provider, egress_ip_amount: 4, device_amount: 50)
      @provider = provider

      @egress_ip_amount = egress_ip_amount
      @device_amount = device_amount
    end

    def call
      @customer = @provider.customers.create(path: @provider.path, name: customer_name, demo: true)

      Seed::EgressIps.new(@customer, amount: @egress_ip_amount).call
      Seed::Devices.new(@customer, amount: @device_amount).call
    end

    private

    def customer_name
      "#{@provider.name} Demo Customer"
    end
  end
end
