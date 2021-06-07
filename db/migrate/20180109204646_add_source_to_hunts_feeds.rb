class AddSourceToHuntsFeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts_feeds, :source, :integer, default: 0, null: false
  end
end
