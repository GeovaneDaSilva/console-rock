module MsGraph
  module SaveTemplates
    # :nodoc
    class UserMfa
      def initialize(account, events)
        @account = account
        @events = events
      end

      def call
        return if @events.blank?

        @events.each do |event|
          billable_instance = billable_instances.find_by(external_id: event["userPrincipalName"])
          next unless billable_instance

          billable_instance.update(mfa_status: event.dig("isMfaRegistered"))
        end
      end

      private

      def billable_instances
        @account
          .all_descendant_billable_instances
          .where(line_item_type: "office_365_mailbox", active: true)
      end
    end
  end
end
