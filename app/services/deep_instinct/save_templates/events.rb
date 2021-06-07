# :nodoc
module DeepInstinct
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Events
      attr_reader :event
      include AntivirusHelper

      STATUS_LOOKUP = {
        "LOW"       => :informational,
        "MODERATE"  => :suspicious,
        "HIGH"      => :malicious,
        "VERY_HIGH" => :malicious,
        "NONE"      => :informational
      }.freeze

      def initialize(app_id, cred, events)
        @app_id  = app_id || Apps::DeepInstinctApp.first.id
        @cred    = cred
        @account = cred.account
        @events  = events
      end

      def call
        return if @events.blank?

        @events.each do |event|
          next if existing_records.where(external_id: event.dig("id").to_i).exists?

          event["is_paying"] = matching_hostname?(event.dig("recorded_device_info", "hostname"))
          res = result(event)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", res) if res.save
        end
      end

      private

      def mapped_customer(event)
        AntivirusCustomerMap.find_by(
          app_id: @app_id, antivirus_id: event["tenant_id"]
        )&.account || @account
      end

      def existing_records
        @account.all_descendant_deep_instinct_results
      end

      def formatted_event(event)
        {
          "type"       => "DeepInstinct",
          "attributes" => event
        }
      end

      def device(event)
        mac_address = event.dig("recorded_device_info", "mac_address")
        hostname = event.dig("recorded_device_info", "hostname")
        Device.where(mac_address: mac_address).or(Device.where(hostname: hostname)).first
      end

      def result(event)
        Apps::DeepInstinctResult.new(
          app_id:         @app_id,
          device_id:      device(event)&.id,
          detection_date: (event.dig("timestamp") || DateTime.current).to_datetime,
          value:          event.dig("action"),
          value_type:     event.dig("type"),
          customer_id:    mapped_customer(event)&.id,
          details:        formatted_event(event),
          credential_id:  @cred.id,
          verdict:        STATUS_LOOKUP[event.dig("threat_severity")],
          account_path:   mapped_customer(event)&.path,
          external_id:    event.dig("id")
        )
      end
    end
  end
end
