class RemoveAccountsCountFromAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :accounts, :accounts_count, :integer
  end
end
