class AddIndexesToAppCounterCaches < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :apps_counter_caches, column: :device_id, algorithm: :concurrently
    add_index :apps_counter_caches, :verdict, algorithm: :concurrently
    add_index :apps_counter_caches, :device_id, where: 'device_id IS NOT NULL', algorithm: :concurrently
  end
end
