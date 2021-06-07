module Reports
  module OfficeUsersMfa
    # Base O365 User 2FA reporter
    class Base
      def initialize(key, account, opts = nil)
        @key = key
        mailboxes = account.all_descendant_billable_instances.office_365_mailbox.active

        @collection = mailboxes.order("updated_at DESC")
        @opts = opts
      end

      def call
        report_class.new(@key, @collection, @opts).call
      end

      private

      def report_class
        raise NotImplementedError
      end
    end
  end
end
