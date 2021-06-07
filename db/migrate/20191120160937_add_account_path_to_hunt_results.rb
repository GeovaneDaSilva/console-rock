class AddAccountPathToHuntResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :hunt_results, :account_path, :ltree

    add_index :hunt_results, :account_path, using: :gist, algorithm: :concurrently
  end
end
