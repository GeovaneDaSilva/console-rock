module Notifiers
  # Invokes the notifier for the specific event type
  class Email < Base
    def call
      Time.use_zone(timezone) do
        klass.new(@subscription, @account, @device, @payload).call
      end
    end

    private

    def timezone
      if @device&.timezone
        @device.timezone
      else
        @account.all_descendant_devices.first&.timezone || "Central Time (US & Canada)"
      end
    end

    def klass
      "Notifiers::Email::#{@type.to_s.camelize}".constantize
    end
  end
end
