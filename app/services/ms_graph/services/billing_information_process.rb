# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class BillingInformationProcess
      def initialize(credential_id, events)
        @cred = Credential.find(credential_id)
        @events = events || []
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @events.blank?

        @events.each do |user|
          next if skip_account?(user.dig("userPrincipalName"))

          licenses = translate_licenses user.dig("assignedLicenses")

          next if licenses.blank?

          result = BillableInstance.where(
            line_item_type: :office_365_mailbox,
            account_path: @cred.customer.path, external_id: user.dig("userPrincipalName"), active: true
          ).first_or_initialize

          result.assign_attributes(
            details: { display_name: user.dig("displayName"), licenses: licenses }
          )

          if result.changed?
            Rails.logger.error("Mailbox billing error -- #{user.dig('id')}") unless result.save
          else
            result.touch
          end
        end
      end

      private

      def licenses_database
        @licenses_database ||= LookupSkus.all
      end

      def translate_licenses(license_list)
        return [] if license_list.blank?

        finals = []

        license_list.each do |item|
          next if item.dig("skuId").nil?

          license_name = licenses_database.where(id: item.dig("skuId")).first

          if license_name.nil?
            ServiceRunnerJob.perform_later("MsGraph::Services::AddLookupSku", @cred, item.dig("skuId"))
          else
            finals << license_name.name
          end
        end
        finals
      end

      def skip_account?(user)
        skip_account_list.include?(user)
      end

      def skip_account_list
        @skip_account_list ||= BillableInstance.where(
          account_path:   @cred.customer.path,
          line_item_type: "office_365_mailbox",
          active:         false
        ).pluck(:external_id)
      end
    end
  end
end
