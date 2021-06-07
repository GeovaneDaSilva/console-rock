# :nodoc
module Passly
  # :nodoc
  module SaveTemplates
    # :nodoc
    class AuditEntries
      def initialize(app_id, cred, audit_entries)
        @app_id        = app_id || Apps::PasslyApp.first.id
        @cred          = cred.is_a?(Integer) ? Credentials::Passly.find(cred) : cred
        @account       = @cred&.account || @cred&.customer
        @audit_entries = audit_entries
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @audit_entries.blank? || @cred.nil?

        @audit_entries.each do |entry|
          next unless existing_records.find_by(external_id: entry.dig("Id")).nil?

          entry["Raw"] = JSON.parse(entry["Raw"])
          result = make_result(entry)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", result) if result.save
        end
      end

      private

      def mapped_customer(entry)
        AntivirusCustomerMap.find_by(
          app_id: @app_id, antivirus_id: entry["OrganizationId"]
        )&.account || @account
      end

      def existing_records
        @account.all_descendant_app_results.where(app_id: @app_id)
      end

      def formatted_audit_entry(entry)
        {
          "type"       => "Passly",
          "attributes" => entry
        }
      end

      def verdict(entry)
        case entry["Severity"]
        when "Information"
          :informational
        when "Warning"
          :suspicious
        when "Critical"
          :malicious
        else
          :informational
        end
      end

      def make_result(entry)
        ::Apps::PasslyResult.new(
          app_id:         @app_id,
          detection_date: DateTime.parse(entry.dig("Created")),
          value:          entry.dig("Success")&.to_s&.titleize || "",
          value_type:     entry.dig("Raw", "record_message") || "",
          customer_id:    mapped_customer(entry)&.id,
          details:        formatted_audit_entry(entry),
          credential_id:  @cred.id,
          verdict:        verdict(entry),
          account_path:   @account.path,
          external_id:    entry.dig("Id")
        )
      end
    end
  end
end
