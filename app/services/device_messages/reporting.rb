module DeviceMessages
  # Reporting endpoint
  class Reporting < Base
    def call
      if payload.blank? || payload.nil?
        Rails.logger.error("Reporting - invalid payload #{@message}")
        return
      end

      # Rails.logger.info("Reporting - Payload: #{payload.to_json}")

      case payload["app_id"]
      when "firewall"
        received_counter = payload.dig("counter", "received") # i.e raw, anything that hits the app
        filtered_counter = payload.dig("counter", "filtered")
        reported_counter = payload.dig("counter", "reported")
        parsed_counter = filtered_counter + reported_counter
        firewall_type = payload.dig("counter", "firewall_type") || :meraki

        make_firewall_counter(device.account_path, firewall_type, received_counter, :received)
        make_firewall_counter(device.account_path, firewall_type, parsed_counter, :parsed)
        make_firewall_counter(device.account_path, firewall_type, filtered_counter, :filtered)
        make_firewall_counter(device.account_path, firewall_type, reported_counter, :reported)

        # Broadcasts::FirewallCount::Status.new(device.account).call
      end
    end

    private

    def make_firewall_counter(path, firewall_type, counter, count_type)
      return if counter.zero?

      record = FirewallCounter.where(
        account_path: path, firewall_type: firewall_type, count_type: count_type
      ).first_or_initialize
      new_count = record.count + counter
      record.assign_attributes(count: new_count)
      record.save
    end
  end
end
