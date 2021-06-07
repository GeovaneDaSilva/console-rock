# :nodoc
module Hibp
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Breaches
      def initialize(app_id, cred_id, breaches, account_id, email = nil)
        @app_id                 = app_id || Apps::HibpApp.first.id
        @cred_id                = cred_id
        @account = Account.find(account_id)
        @breaches = breaches
        @email = email
      rescue ActiveRecord::RecordNotFound
        @account = nil
      end

      def call
        return if @breaches.blank? || @account.blank?

        @breaches.each do |breach|
          # in a perfect world, we would not pull duplicate data every day at all
          # (rather than filtering it out)
          next unless existing_records.find_by(external_id: breach.dig("Name")).nil?
          next if breach.dig("IsRetired") || breach.dig("IsSpamList")

          breach["email"] ||= @email unless @email.nil?
          result = result(breach)

          ServiceRunnerJob.perform_later("Apps::Results::Processor", result) if result.save
        end
      end

      private

      def existing_records
        @account.all_descendant_app_results.where(app_id: @app_id)
      end

      def formatted_threat(breach)
        {
          "type"       => "Hibp",
          "attributes" => breach
        }
      end

      def result(breach)
        ::Apps::HibpResult.new(
          app_id:         @app_id,
          detection_date: DateTime.parse(breach.dig("BreachDate")),
          value:          breach.dig("email") || breach.dig("Domain"),
          value_type:     breach.dig("Name"),
          customer_id:    @account.id,
          details:        formatted_threat(breach),
          credential_id:  @cred_id,
          verdict:        "informational",
          account_path:   @account.path,
          external_id:    breach["Name"]
        )
      end
    end
  end
end
