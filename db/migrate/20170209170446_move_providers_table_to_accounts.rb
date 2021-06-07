class MoveProvidersTableToAccounts < ActiveRecord::Migration[5.0]
  def change
    rename_table :providers, :accounts
    add_column :accounts, :type, :string, default: "Provider"

    add_index :accounts, [:type, :id]
  end
end
