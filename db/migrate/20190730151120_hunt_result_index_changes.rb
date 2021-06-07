class HuntResultIndexChanges < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :hunt_results, :hunt_revision_id
    remove_index :hunt_results, :tags

    add_index :hunt_results, :created_at, algorithm: :concurrently
    add_index :hunt_results, [:hunt_id, :hunt_revision_id], algorithm: :concurrently
  end
end
