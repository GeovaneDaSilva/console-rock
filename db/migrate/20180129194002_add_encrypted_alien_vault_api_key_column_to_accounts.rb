class AddEncryptedAlienVaultApiKeyColumnToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :encrypted_alien_vault_api_key, :string
    add_column :accounts, :encrypted_alien_vault_api_key_iv, :string
    remove_column :accounts, :alien_vault_api_key
  end
end
