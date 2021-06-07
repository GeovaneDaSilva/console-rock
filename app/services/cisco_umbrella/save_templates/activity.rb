# :nodoc
module CiscoUmbrella
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Activity
      def initialize(cred, activity_hash, app_id = nil, customer = nil)
        @app_id                 = app_id || Apps::CiscoUmbrellaApp.first.id
        @cred                   = cred.is_a?(Integer) ? Credentials::CiscoUmbrella.find(cred) : cred
        @customer               = @cred&.account || customer
        @activity_hash          = activity_hash
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @cred.nil? || @customer.nil? || @app_id.nil?
        return if existing_result?

        result = result(@activity_hash)
        ServiceRunnerJob.perform_later("Apps::Results::Processor", result) if result.save
      end

      private

      def digest
        Digest::MD5.hexdigest([@activity_hash.dig("timestamp"),
                               @activity_hash.dig("externalip")].join)
      end

      def existing_result?
        existing_records.where(external_id: digest).any?
      end

      def existing_records
        @existing_records ||= Apps::CiscoUmbrellaResult.where(app_id:      @app_id,
                                                              customer_id: @customer.id).order(:app_id)
      end

      def formatted
        {
          "type"       => "CiscoUmbrella",
          "attributes" => @activity_hash
        }
      end

      def device
        Device.where(ipv4_address: [@activity_hash.dig("internalip"),
                                    @activity_hash.dig("externalip")]).first
      end

      def result(activity_hash)
        ::Apps::CiscoUmbrellaResult.new(
          app_id:         @app_id,
          device_id:      device&.id,
          detection_date: Time.at(activity_hash.dig("timestamp").to_i).utc,
          value:          activity_hash.dig("externalip"),
          value_type:     activity_hash.dig("type"),
          customer:       @customer,
          details:        formatted,
          credential_id:  @cred.id,
          # no documentation on the types of verdict; setting it as 'informational'
          verdict:        "informational",
          account_path:   @customer.path,
          external_id:    digest
        )
      end
    end
  end
end
