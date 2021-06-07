module Devices
  # Check for devices which have been inactive
  class InactiveChecker
    def call
      settings.find_each do |setting|
        # rubocop:disable Rails/Blank
        nearest_setting_with_thresholds = find_nearest_setting_with_thresholds(setting)
        next unless nearest_setting_with_thresholds.present?

        # rubocop:enable Rails/Blank
        process_thresholds(nearest_setting_with_thresholds)
      end
    end

    private

    def settings
      Setting.where.not(device_inactivity_thresholds: [nil, {}])
    end

    # rubocop:disable Style/InverseMethods
    def descendant_customer_accounts_without_settings(provider)
      provider.all_descendant_customers.select do |descendant_customer|
        !descendant_customer.account.setting.nil?
      end
    end
    # rubocop:enable Style/InverseMethods

    def find_nearest_setting_with_thresholds(setting)
      account = setting.account
      settings.joins(:account)
              .merge(account.self_and_ancestors.order(path: :desc))
              .limit(1)
              .first
    end

    def process_thresholds(setting)
      account = setting.account
      return if account.nil?

      (setting.device_inactivity_thresholds || {}).each do |device_type, seconds|
        next if seconds.blank?

        if account.provider?
          descendant_customer_accounts_without_settings(account).each do |customer_account|
            process_stale_devices(customer_account, device_type, seconds.to_i)
          end
        else
          process_stale_devices(account, device_type, seconds.to_i)
        end
      end
    end

    def process_stale_devices(account, device_type, seconds)
      devices = stale_devices(account, device_type, seconds)
      stale_syslog_devices = stale_syslog_devices(account, devices)
      body = payload(devices, stale_syslog_devices, account)

      subscriptions(account).each do |subscription|
        ServiceRunnerJob.set(queue: :utility).perform_later(
          "Notifiers::Email::DeviceInactivity",
          subscription,
          account,
          devices.to_a,
          stale_syslog_devices,
          body
        )
      end
    end

    def subscriptions(account)
      Subscriptions::Email.where(account: account.self_and_ancestors)
    end

    def stale_devices(account, device_type, sec)
      return [] if sec.blank? || sec.zero?

      # All device_type values on prod are nil
      if device_type == "others"
        account.devices.offline.where("last_connected_at <= ?", sec.seconds.ago).where(device_type: nil)
      else
        account.devices.send(device_type).offline.where("last_connected_at <= ?", sec.seconds.ago)
      end
    end

    def stale_syslog_devices(account, stale_devices)
      syslogs = syslog_devices(account)
      stale_devices.collect do |d|
        d if syslogs.include? d.hostname
      end.uniq.compact
    end

    def syslog_devices(account)
      account.app_configs.joins(:app)
             .where(apps: { configuration_type: "syslog" })
             .collect { |c| c.config.dig("hostname") }
    end

    def payload(devices, stale_syslog_devices, account)
      {
        inactive_device: {
          message: {
            text: InactivityBuilder.new(devices, account, :text).call,
            html: InactivityBuilder.new(devices, account, :html).call
          }
        },
        syslog:          syslog_payload(stale_syslog_devices, account)
      }
    end

    def syslog_payload(stale_syslog_devices, account)
      return {} if stale_syslog_devices.blank?

      {
        message: {
          text: InactivityBuilder.new(stale_syslog_devices, account, :text, :syslog).call,
          html: InactivityBuilder.new(stale_syslog_devices, account, :html, :syslog).call
        }
      }
    end
  end
end
