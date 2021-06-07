module Accounts
  module Apps
    # :nodoc
    class IncidentsMailer < ApplicationMailer
      default from: "#{I18n.t('application.name', default: 'SOC')} Managed Services " \
                    "<#{ENV.fetch(I18n.t('application.notification_email'), 'support@console.test')}>"

      def notify(account, incident)
        @account  = account
        @incident = incident
        return unless subscription || @account.managed?

        set_locale
        subscription.each do |one_sub|
          email_managed_notification(one_sub)
        end
      end

      private

      def subscription
        return @subscription unless @subscription.nil?

        @subscription ||= @account.subscriptions.with_event_types(:managed_service_event_summary)
        @subscription = [nil] if @subscription.empty?
      end

      def payload_builder(format)
        ApplicationController.renderer.render(
          partial: "/accounts/apps/incidents/summary", locals: { incident: @incident }, formats: format
        )
      end

      def email_managed_notification(one_sub)
        return if @account.customer? && !allow_customer_notifications

        recipient_email = one_sub&.email_address&.split(",")
        return unless recipient_email

        mail(
          to:      recipient_email,
          bcc:     ENV.fetch("SOC_EMAIL", "soc@console.test"),
          subject: "ACTION REQUIRED - #{I18n.t('application.name')} Managed Service Incident"
        )
      end

      def allow_customer_notifications
        @account.self_and_all_ancestors.pluck(:enable_customer_notifications).include?(true)
      end

      def set_locale
        I18n.locale = extract_locale || I18n.default_locale
      end

      def extract_locale
        locale = @account.billing_account&.plan&.plan_type
        I18n.available_locales.map(&:to_s).include?(locale) ? locale : nil
      end
    end
  end
end
