class AddAccountPathToAppsResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :apps_results, :account_path, :ltree

    add_index :apps_results, :account_path, using: :gist, algorithm: :concurrently
  end
end
