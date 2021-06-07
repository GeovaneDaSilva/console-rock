class AddOffice365MailboxAttributesToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :included_office_365_mailboxes, :integer
    add_column :plans, :price_per_office_365_mailbox_overage_cents, :integer
    add_column :plans, :price_per_office_365_mailbox_overage_currency, :string

    change_column_default :plans, :price_per_office_365_mailbox_overage_cents, from: nil, to: 0
    change_column_default :plans, :price_per_office_365_mailbox_overage_currency, from: nil, to: "USD"
  end
end
