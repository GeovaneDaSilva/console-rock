class AddLastRefreshedToHuntsFeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts_feeds, :last_refreshed, :datetime
  end
end
