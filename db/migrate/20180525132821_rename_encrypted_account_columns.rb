class RenameEncryptedAccountColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :api_keys, :jsonb

    safety_assured do
      rename_column :accounts, :encrypted_alien_vault_api_key, :encrypted_old_alien_vault_api_key
      rename_column :accounts, :encrypted_alien_vault_api_key_iv, :encrypted_old_alien_vault_api_key_iv

      rename_column :accounts, :encrypted_virus_total_api_key, :encrypted_old_virus_total_api_key
      rename_column :accounts, :encrypted_virus_total_api_key_iv, :encrypted_old_virus_total_api_key_iv
    end

    reversible do |dir|
      dir.up do
        Account.reset_column_information

        accounts = Account.where
               .not(encrypted_old_virus_total_api_key: nil)
               .or(Account.where.not(encrypted_old_virus_total_api_key: nil))
        accounts.find_each do |account|
          account.update(alien_vault_api_key: account.old_alien_vault_api_key)
          account.update(virus_total_api_key: account.old_virus_total_api_key)
        end
      end
    end
  end
end
