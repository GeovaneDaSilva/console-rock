module Notifiers
  class Email
    # :nodoc
    class DeviceInactivity
      def initialize(subscription, account, devices, syslog_devices, payload)
        @subscription = subscription
        @account      = account
        @devices      = devices
        @payload      = payload
        @syslog_devices = syslog_devices
      end

      def call
        if @devices.count.positive?
          NotificationMailer.device_inactivity(
            email_address, @account, @payload.dig(:inactive_device, :message)
          ).deliver_later
        end

        return unless @syslog_devices.count.positive?

        @syslog_devices.each do |syslog_device|
          emails = device_owner_emails(syslog_device) + [@subscription.email_address]
          NotificationMailer.syslog_server_offline(
            emails.uniq.join(","), @account, @payload.dig(:syslog, :message)
          ).deliver_later
        end
      end

      private

      def email_address
        @subscription.email_address.presence || @account.owners.first&.email
      end

      def device_owner_emails(syslog_device)
        owner_emails = []
        @account.app_configs.joins(:app)
                .where(apps: { configuration_type: "syslog" })
                .where("config->>'hostname' = ?", syslog_device.hostname)
                .each do |config|
                  owner_emails += config.account.owners&.map(&:email)
                end
        owner_emails
      end
    end
  end
end
