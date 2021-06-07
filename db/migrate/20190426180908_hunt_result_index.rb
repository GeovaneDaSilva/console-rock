class HuntResultIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_index :hunt_results, [:device_id, :result, :archived, :created_at, :hunt_id], algorithm: :concurrently, name: "hunt_result_stat_idx"
    end
  end
end
