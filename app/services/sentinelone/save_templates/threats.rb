# :nodoc
module Sentinelone
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Threats
      include AntivirusHelper
      STATUS_LOOKUP = {
        "active"              => "malicious",
        "mitigated"           => "informational",
        "blocked"             => "informational",
        "suspicious"          => "suspicious",
        "pending"             => "suspicious",
        "suspicious_resolved" => "informational"
      }.freeze

      def initialize(app_id, cred, events)
        if events.blank?
          @events = []
        else
          @app_id                 = app_id || Apps::SentineloneApp.first.id
          @cred                   = cred
          @account                = cred.account
          @events                 = events
          @last_result            = last_result

          create_mapper(cred.account.self_and_all_descendant_customers)
        end
      end

      def call
        return if @events.blank?

        @last_result.destroy_all if @last_result.any?

        @events.each do |event|
          event_id = event["id"]
          existing_result = fetch_existing_result(event_id)
          event["is_paying"] = matching_hostname?(event["agentComputerName"])
          result = if existing_result.present?
                     update_result(existing_result, event)
                   else
                     create_result(event)
                   end

          if result.save && existing_result.blank?
            ServiceRunnerJob.perform_later("Apps::Results::Processor", result)
          end
        end
      end

      private

      def fetch_existing_result(event_id)
        existing_records.find_by(external_id: event_id)
      end

      def existing_records
        @account.all_descendant_sentinelone_results
      end

      def last_result
        existing_records.malicious.where("details ->> 'type' = 'SentineloneError'")
      end

      def formatted_event(event)
        {
          "type"       => "Sentinelone",
          "attributes" => event
        }
      end

      def mapped_customer(event)
        customer = @mapper.dig(event.dig("siteName")) || @mapper.dig(event.dig("agentDomain"))
        customer || @mapper.dig(event.dig("siteId")) || @account
      end

      def create_mapper(accounts)
        @mapper = AntivirusCustomerMap.where(
          app_id:     @app_id,
          account_id: accounts
        ).map { |one| [one.antivirus_id, Account.find_by(id: one.account_id)] }.to_h
        @mapper[nil] = nil
      end

      def create_result(event)
        return if mapped_customer(event).nil?

        Apps::SentineloneResult.new(
          app_id:         @app_id,
          detection_date: (event.dig("createdAt") || DateTime.current).to_datetime,
          value:          CGI.unescape(event.dig("threatName")) || "",
          value_type:     "",
          customer_id:    mapped_customer(event)&.id,
          details:        formatted_event(event),
          credential_id:  @cred.id,
          verdict:        STATUS_LOOKUP[event.fetch("mitigationStatus", "suspicious")],
          account_path:   mapped_customer(event)&.path,
          external_id:    event.dig("id")
        )
      end

      def update_result(result, event)
        attributes = {
          details: formatted_event(event),
          verdict: STATUS_LOOKUP[event.fetch("mitigationStatus", "suspicious")]
        }
        result.assign_attributes(attributes)
        result
      end
    end
  end
end
