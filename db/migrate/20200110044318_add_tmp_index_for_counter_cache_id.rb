class AddTmpIndexForCounterCacheId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, :counter_cache_id, algorithm: :concurrently
  end
end
