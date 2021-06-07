class AddVirusTotalApiKeyValuesToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :encrypted_virus_total_api_key, :string
    add_column :accounts, :encrypted_virus_total_api_key_iv, :string
  end
end
