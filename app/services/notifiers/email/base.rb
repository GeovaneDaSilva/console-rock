module Notifiers
  class Email
    # Base class for email notifiers
    class Base
      def initialize(subscription, account, device, payload)
        @subscription = subscription
        @account      = account
        @device       = device
        @payload      = payload
      end

      def call
        raise NotImplementedError
      end

      private

      def skip_notification?
        @subscription.disabled_apps.to_a.compact.include?(@payload[:app_id])
      end
    end
  end
end
