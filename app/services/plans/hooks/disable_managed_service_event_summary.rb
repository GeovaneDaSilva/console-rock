module Plans
  module Hooks
    # :nodoc
    class DisableManagedServiceEventSummary < Base
      def call
        return unless existing_managed_subscription?

        existing_email_subscription.update_all(event_types: []) if existing_email_subscription
      end

      private

      def existing_managed_subscription?
        subscriptions.with_event_types(:managed_service_event_summary).any?
      end

      def existing_email_subscription
        @existing_email_subscription ||= subscriptions.email
      end

      def subscriptions
        @subscriptions ||= @account.subscriptions
      end
    end
  end
end
