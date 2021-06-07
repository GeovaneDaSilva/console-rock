class AddSystemHuntFeedToHunts < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :system_hunt_feed, :boolean, default: false
  end
end
