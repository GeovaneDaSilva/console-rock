# :nodoc
module Sophos
  # :nodoc
  module SaveTemplates
    # :nodoc
    class FirewallUtm
      VERDICT_LOOKUP = {
        "high"   => :malicious,
        "medium" => :suspicious,
        "low"    => :informational,
        nil      => :informational
      }.freeze

      def initialize(account_id, credential_id, data_json)
        # @account     = Account.find_by_id(account_id)
        # @credential = Credential.find_by_id(credential_id)
        # @data = JSON.parse(@data_json)
        # @app = App.find_by_configuration_type("syslog")
      end

      def call
        return if @account.nil? || @credential.nil? || @data.blank?

        @data.each do |firewall_event|
          next if VERDICT_LOOKUP[firewall_event.dig("severity")] == :informational
          next if existing_results.where(external_id: firewall_event.dig("id")).take.present?

          app_result = build_app_result(firewall_event)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", app_result) if app_result.save
        end
      end

      private

      def existing_results
        @existing_results ||= @credential.account.all_descendant_app_results.where(app_id: @app_id)
      end

      def build_app_result(alert)
        ::Apps::SophosResult.new(
          app_id:         @app_id,
          detection_date: (alert.dig("raisedAt") || DateTime.current).to_datetime,
          value:          alert.dig("type"),
          value_type:     alert.dig("category"),
          customer_id:    @account.id,
          details:        alert,
          credential_id:  @credential.id,
          verdict:        VERDICT_LOOKUP.fetch(alert.dig("severity"), :suspicious),
          account_path:   @account.path,
          external_id:    alert.dig("id")
        )
      end
    end
  end
end
