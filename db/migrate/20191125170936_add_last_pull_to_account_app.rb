class AddLastPullToAccountApp < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :account_apps, :last_pull, :datetime

    add_index :account_apps, :last_pull, algorithm: :concurrently
  end
end
