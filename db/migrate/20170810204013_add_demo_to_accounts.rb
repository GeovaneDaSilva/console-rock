class AddDemoToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :demo, :boolean, default: false, null: false
  end
end
