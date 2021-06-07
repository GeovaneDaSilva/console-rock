class MoveOffice365MailboxesToBillableItems < ActiveRecord::Migration[5.2]
  def up
    # Office365Mailbox.find_each do |mailbox|
    #   BillableInstance.create(
    #     mailbox.attributes.merge(line_item_type: :office_365_mailbox)
    #   )
    # end
  end
end
