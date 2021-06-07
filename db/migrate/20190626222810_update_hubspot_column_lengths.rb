class UpdateHubspotColumnLengths < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      change_column :accounts, :hubspot_company_id, :string
      change_column :users, :hubspot_contact_id, :string
    end
  end

  def down
    safety_assured do
      change_column :accounts, :hubspot_company_id, :integer
      change_column :users, :hubspot_contact_id, :integer
    end
  end
end
