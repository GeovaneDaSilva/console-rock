# :nodoc
module Duo
  # :nodoc
  module SaveTemplates
    # :nodoc
    class AdminLogs
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

        duo_result = build_result
        ServiceRunnerJob.perform_later("Apps::Results::Processor", duo_result) if duo_result.save
      end

      private

      def external_id
        Digest::MD5.hexdigest([@log.dig("timestamp"),
                               @log.dig("username"),
                               @log.dig("action")].join)
      end

      def existing_result?
        existing_records.where(external_id: external_id).exists?
      end

      def existing_records
        @existing_records ||= ::Apps::Result.where(app_id: @app_id, customer_id: @customer.id)
                                            .order(:app_id)
      end

      def formatted_log
        {
          "type"       => "AdminLog",
          "attributes" => @log
        }
      end

      def build_result
        ::Apps::DuoResult.new(
          app_id:         @app_id,
          detection_date: DateTime.strptime(@log.dig("timestamp").to_s, "%s"),
          value:          @log.dig("username"),
          value_type:     @log.dig("action"),
          customer_id:    @customer.id,
          details:        formatted_log,
          credential_id:  @cred.id,
          verdict:        "informational",
          account_path:   @customer.path,
          external_id:    external_id
        )
      end
    end
  end
end
