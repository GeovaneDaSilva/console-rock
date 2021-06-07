# :nodoc
module Sophos
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Alerts
      VERDICT_LOOKUP = {
        "high"   => :malicious,
        "medium" => :suspicious,
        "low"    => :informational
      }.freeze

      def initialize(app_id, credential, data_json)
        @app_id     = app_id
        @credential = credential
        @data_json  = data_json
      end

      def call
        return if @data_json.blank?

        data = JSON.parse(@data_json)
        accounts = Account.where(id: data.keys)
        accounts.each do |account|
          alerts = data[account.id.to_s]
          process_alerts(account, alerts)
        end
      end

      private

      def process_alerts(account, alerts)
        # firewall_results, antivirus_results = alerts&.partition { |n| n
        # .dig("managedAgent", "type") == "utm" }
        # return if antivirus_results.nil?

        # ServiceRunnerJob.perform_later("Sophos::SaveTemplates::FirewallUtm", account.id, @credential.id,
        # firewall_results.to_json)

        (alerts || []).each do |alert|
          next if alert.dig("managedAgent", "type") == "utm"
          next if existing_results.where(external_id: alert.dig("id")).exists?

          app_result = build_app_result(account, alert)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", app_result) if app_result.save
        end
      end

      def existing_results
        @existing_results ||= @credential.account.all_descendant_app_results.where(app_id: @app_id)
      end

      def build_app_result(account, alert)
        ::Apps::SophosResult.new(
          app_id:         @app_id,
          detection_date: (alert.dig("raisedAt") || DateTime.current).to_datetime,
          value:          alert.dig("managedAgent", "id") || alert.dig("tenant", "name"),
          value_type:     alert.dig("managedAgent", "type") || alert.dig("category"),
          customer_id:    account.id,
          details:        alert,
          credential_id:  @credential.id,
          verdict:        VERDICT_LOOKUP.fetch(alert.dig("severity"), :suspicious),
          account_path:   account.path,
          external_id:    alert.dig("id")
        )
      end
    end
  end
end
