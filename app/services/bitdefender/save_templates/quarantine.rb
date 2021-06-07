# :nodoc
module Bitdefender
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Quarantine
      # computers:
      # 0-None 1-Pendingremove 2-Pendingrestore 3-Removefailed 4-Restorefailed 16-PendingSave 17-FailedSave

      # exchange: 0-spam 1-suspected 2-infected 3-attachementdetection 4-contentdetection 5-unscannable
      include AntivirusHelper
      STATUS_LOOKUP = {
        "computers" => {
          0  => "suspicious",
          1  => "informational",
          2  => "informational",
          3  => "malicious",
          4  => "malicious",
          16 => "informational",
          17 => "malicious"
        },
        "exchange"  => {
          0 => "suspicious",
          1 => "suspicious",
          2 => "malicious",
          3 => "informational",
          4 => "informational",
          5 => "suspicious"
        }
      }.freeze

      def initialize(app_id, cred, events, type)
        if events.blank?
          @events = []
        else
          @app_id  = app_id || Apps::BitdefenderApp.first.id
          @cred    = cred
          @account = cred.account
          @events  = events
          @type    = type

          create_mapper(cred.account.self_and_all_descendant_customers)
        end
      end

      def call
        return if @events.blank?

        @events.each do |event|
          next if existing_records.where(external_id: event.dig("id")).exists?

          event["is_paying"] = matching_hostname?(event["endpointName"])
          result = result(event)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", result) if result.save
        end
      end

      private

      def existing_records
        @account.all_descendant_bitdefender_results
      end

      def formatted_event(event)
        {
          "type"       => "Bitdefender",
          "attributes" => event
        }
      end

      def mapped_customer(event)
        @mapper.dig(event.dig("companyId")) || @account
      end

      def create_mapper(accounts)
        @mapper = AntivirusCustomerMap.where(
          app_id:     @app_id,
          account_id: accounts
        ).map { |one| [one.antivirus_id, Account.find_by(id: one.account_id)] }.to_h
        @mapper[nil] = nil
      end

      def result(event)
        return if mapped_customer(event).nil?

        Apps::BitdefenderResult.new(
          app_id:         @app_id,
          detection_date: (event.dig("quarantinedOn") || DateTime.current).to_datetime,
          value:          event.dig("threatName") || "",
          value_type:     "Quarantine",
          customer_id:    mapped_customer(event)&.id,
          details:        formatted_event(event),
          credential_id:  @cred.id,
          verdict:        verdict(event),
          account_path:   mapped_customer(event)&.path,
          external_id:    event.dig("id")
        )
      end

      def verdict(event)
        crumbs = @type == "computers" ? %w[actionStatus] : %w[details threatStatus]
        STATUS_LOOKUP[@type][event.dig(*crumbs)]
      end
    end
  end
end
