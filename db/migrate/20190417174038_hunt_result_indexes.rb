class HuntResultIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :hunt_results, [:device_id, :created_at, :archived], algorithm: :concurrently
  end
end
