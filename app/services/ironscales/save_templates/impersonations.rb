# :nodoc
module Ironscales
  # :nodoc
  module SaveTemplates
    # :Saves IronScales e-mail impersonation events
    class Impersonations
      def initialize(cred, incident, company_id)
        @app_id                 = Apps::IronscalesApp.first.id
        @cred                   = cred.is_a?(Integer) ? Credentials::Ironscales.find(cred) : cred
        @account                = @cred&.account
        @incidents = incident&.dig("incidents")
        @company_id = company_id
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @cred.nil? || @incidents.blank?

        @incidents.each do |incident|
          next if existing_results.where(external_id: incident["incidentID"].to_s).exists?

          res = result(incident)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", res) if res.save
        end
      end

      private

      def existing_results
        @account&.all_descendant_app_results&.where(app_id: @app_id)
      end

      def mapped_customer(_incident)
        mapped_customers.find_by(antivirus_id: @company_id)&.account || @account
      end

      def mapped_customers
        @mapped_customers ||= AntivirusCustomerMap.where(app_id: @app_id)
      end

      def formatted_event(incident)
        {
          "type"       => "Ironscales",
          "attributes" => incident
        }
      end

      def result(incident)
        ::Apps::IronscalesResult.new(
          app_id:         @app_id,
          detection_date: DateTime.parse(incident.dig("remediatedTime") || DateTime.current.to_s),
          value:          incident.dig("incidentType") || "",
          value_type:     incident.dig("subject") || "",
          customer_id:    mapped_customer(incident)&.id,
          details:        formatted_event(incident),
          credential_id:  @cred.id,
          verdict:        "suspicious",
          account_path:   mapped_customer(incident)&.path,
          external_id:    incident.dig("incidentID")
        )
      end
    end
  end
end
