class CreateHuntsFeedResults < ActiveRecord::Migration[5.1]
  def change
    rename_table :hunts_cymon_feed_results, :hunts_feed_results
    rename_column :hunts_feed_results, :provider, :author_name
    rename_column :hunts_feed_results, :ioc, :indicators
    rename_column :hunts, :cymon_feed_result_id, :feed_result_id
  end
end
