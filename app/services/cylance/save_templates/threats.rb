# :nodoc
module Cylance
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Threats
      def initialize(app_id, cred, threat)
        @app_id                 = app_id || Apps::CylanceApp.first.id
        @cred                   = cred.is_a?(Integer) ? Credentials::Cylance.find(cred) : cred
        @customer               = @cred.customer
        @threat                 = threat
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @threat.blank? || @cred.nil?

        devices = Cylance::Services::Pull.new(@cred.id, { url: device_threat_url(@threat["sha256"]) }).call
        devices.dig("page_items").each do |device_hash|
          device = get_device(device_hash)

          next if existing_result?(device_hash)

          result = result(device, device_hash)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", result) if result.save
        end
      end

      private

      def device_threat_url(threat_hash)
        "https://protectapi.cylance.com/threats/v2/#{threat_hash}/devices"
      end

      def existing_result?(device_hash)
        external_id = Digest::MD5.hexdigest([@threat.dig("sha256"), device_hash.dig("id")].join)
        !existing_records.find_by(external_id: external_id).nil?
      end

      def existing_records
        ::Apps::Result.where(app_id: @app_id, customer_id: @customer.id)
      end

      def formatted_threat(device)
        threat_dup = @threat.deep_dup
        threat_dup["threat_name"] = threat_dup.delete("name")
        device["device_name"] = device.delete("name")
        {
          "type"       => "Cylance",
          "attributes" => device.merge(threat_dup)
        }
      end

      def get_device(device_hash)
        mac_address = device_hash["mac_addresses"].first
        ip_address  = device_hash["ip_addresses"].first
        Device.where(mac_address: mac_address, ipv4_address: ip_address).first
      end

      def result(device, device_hash)
        ::Apps::CylanceResult.new(
          app_id:         @app_id,
          device_id:      device&.id,
          detection_date: DateTime.parse(@threat.dig("last_found")),
          value:          @threat.dig("name"),
          value_type:     @threat.dig("name"),
          customer:       @customer,
          details:        formatted_threat(device_hash),
          credential_id:  @cred.id,
          verdict:        "suspicious",
          account_path:   @customer.path,
          external_id:    Digest::MD5.hexdigest([@threat.dig("sha256"), device_hash.dig("id")].join)
        )
      end
    end
  end
end
