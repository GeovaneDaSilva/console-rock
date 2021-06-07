module Plans
  module Hooks
    # :nodoc
    class EnableManagedServiceEventSummary < Base
      def call
        return if existing_managed_subscription?

        if subscriptions.empty?
          create_new_subscription
        elsif existing_email_subscription
          managed_email
        end
      end

      private

      def existing_managed_subscription?
        subscriptions.with_event_types(:managed_service_event_summary).any?
      end

      def existing_email_subscription
        @existing_email_subscription ||= subscriptions.email.first
      end

      def subscriptions
        @subscriptions ||= @account.subscriptions
      end

      def email_addresses
        emails = @account.owners.pluck(:email).join(",")

        if emails.blank?
          emails = UserRole.joins(:user).where(account: @account.self_and_ancestors, role: "owner")
                           .pluck(:email).join(",")
        end

        emails
      end

      def create_new_subscription
        @account.subscriptions.email.create(
          event_types:      [:managed_service_event_summary],
          email_address:    email_addresses,
          send_blank_email: true
        )
      end

      def managed_email
        existing_email_subscription.update(
          event_types: [:managed_service_event_summary]
        )
      end
    end
  end
end
