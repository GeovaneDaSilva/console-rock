class AddAlienVaultApiKeyToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :alien_vault_api_key, :string
  end
end
