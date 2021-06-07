# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class RemoveOldUsers
      def call
        paths = BillableInstance.office_365_mailbox
                                .joins("join accounts on billable_instances.account_path = accounts.path")
                                .where(accounts: { path: nil }).group(:account_path).count.keys

        BillableInstance.office_365_mailbox.where(account_path: paths).destroy_all
      end
    end
  end
end
