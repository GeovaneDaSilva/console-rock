class RemoveHubspotColumns < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :users, :hubspot_updated_at
      remove_column :users, :hubspot_contact_id
      remove_column :accounts, :hubspot_updated_at
      remove_column :accounts, :hubspot_company_id
    end
  end
end
