class AddCounterCacheIdToAppsResults < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_results, :counter_cache_id, :integer
  end
end
