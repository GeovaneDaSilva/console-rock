class RmAttrEncryptedColumns < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :accounts, :encrypted_old_alien_vault_api_key, :string
      remove_column :accounts, :encrypted_old_alien_vault_api_key_iv, :string

      remove_column :accounts, :encrypted_old_virus_total_api_key, :string
      remove_column :accounts, :encrypted_old_virus_total_api_key_iv, :string
    end
  end
end
