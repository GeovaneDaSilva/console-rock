# :nodoc
module Duo
  # :nodoc
  module SaveTemplates
    # :nodoc
    class RetrieveEvents
      def initialize(app_id, cred, log)
        @app_id    = app_id || Apps::DuoApp.first.id
        @cred      = cred.is_a?(Integer) ? Credentials::Duo.find(cred) : cred
        @customer  = @cred.account || @cred.customer
        @log       = log
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return nil if existing_result?

        result = result(device)
        ServiceRunnerJob.perform_later("Apps::Results::Processor", result) if result.save
      end

      private

      def existing_result?
        existing_records.where(external_id: @log.dig("surfaced_auth", "txid")).exists?
      end

      def existing_records
        @existing_records ||= ::Apps::Result.where(app_id: @app_id, customer_id: @customer.id)
                                            .order(:app_id)
      end

      def formatted_log
        {
          "type"       => "RetrieveEvent",
          "attributes" => @log
        }
      end

      def device
        Device.where(ipv4_address: @log.dig("surfaced_auth", "access_device", "ip")).first
      end

      def result(device)
        ::Apps::DuoResult.new(
          app_id:         @app_id,
          device_id:      device&.id,
          detection_date: DateTime.strptime(@log.dig("surfaced_timestamp").to_s, "%s"),
          value:          @log.dig("sekey"),
          value_type:     @log.dig("type"),
          customer_id:    @customer.id,
          details:        formatted_log,
          credential_id:  @cred.id,
          verdict:        @log.dig("low_risk_ip") ? "informational" : "suspicious",
          account_path:   @customer.path,
          external_id:    @log.dig("surfaced_auth", "txid")
        )
      end
    end
  end
end
