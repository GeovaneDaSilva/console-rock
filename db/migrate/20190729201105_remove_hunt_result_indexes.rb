class RemoveHuntResultIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :hunt_results, [:device_id, :result, :archived, :created_at, :hunt_id]
    remove_index :hunt_results, [:device_id, :created_at, :archived]
  end
end
