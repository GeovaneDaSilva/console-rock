module DeviceBroadcasts
  # Publish call to clients connected via websocket with a given license key
  class Customer < Base
    def initialize(customer, message)
      @customer = customer
      @message  = message
    end

    def call
      @customer.devices.pluck(:id).each do |device_id|
        DeviceBroadcasts::Device.new(device_id, @message, true).call
      end

      true
    end
  end
end
