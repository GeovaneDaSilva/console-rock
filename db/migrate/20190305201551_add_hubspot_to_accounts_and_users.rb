class AddHubspotToAccountsAndUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :hubspot_updated_at, :datetime
    add_column :accounts, :hubspot_company_id, :integer
    add_column :users, :hubspot_updated_at, :datetime
    add_column :users, :hubspot_contact_id, :integer
  end
end
