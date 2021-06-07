class FixCounterColumnOnProviders < ActiveRecord::Migration[5.0]
  def change
    remove_column :providers, :account_count, :integer
    add_column :providers, :accounts_count, :integer, default: 0
  end
end
