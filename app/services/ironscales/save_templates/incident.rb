# :nodoc
module Ironscales
  # :nodoc
  module SaveTemplates
    # :Saves IronScales e-mail incident events (mostly phishing)
    class Incident
      def initialize(cred, incident, _company_id)
        @app_id                 = Apps::IronscalesApp.first.id
        @cred                   = cred.is_a?(Integer) ? Credentials::Ironscales.find(cred) : cred
        @account                = @cred.account
        @incident = incident
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @cred.nil? || @incident.blank?
        return if existing_results.where(external_id: @incident["incident_id"]).exists?

        res = result
        ServiceRunnerJob.perform_later("Apps::Results::Processor", res) if res.save
      end

      private

      def existing_results
        @account.all_descendant_app_results.where(app_id: @app_id)
      end

      def mapped_customer
        AntivirusCustomerMap.find_by(
          app_id: @app_id, antivirus_id: @incident["company_id"]
        )&.account || @account
      end

      def formatted_event
        {
          "type"       => "Ironscales",
          "attributes" => @incident
        }
      end

      def result
        ::Apps::IronscalesResult.new(
          app_id:         @app_id,
          detection_date: DateTime.parse(@incident.dig("first_reported_date")),
          value:          @incident.dig("themis_verdict") || "",
          value_type:     @incident.dig("classification") || "",
          customer_id:    mapped_customer&.id,
          details:        formatted_event,
          credential_id:  @cred.id,
          verdict:        "suspicious",
          account_path:   mapped_customer&.path,
          external_id:    @incident.dig("incident_id")
        )
      end
    end
  end
end
