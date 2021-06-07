class RemoveSystemHuntFeedFromHunts < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      reversible do |dir|
        dir.up { remove_column :hunts, :system_hunt_feed, :boolean, default: false }

        dir.down do
          add_column :hunts, :system_hunt_feed, :boolean, default: false
          Hunt.reset_column_information

          Hunt.where.not(system_hunts_category_id: nil).find_each do |hunt|
            hunt.update(system_hunt_feed: true)
          end
        end
      end
    end
  end
end
