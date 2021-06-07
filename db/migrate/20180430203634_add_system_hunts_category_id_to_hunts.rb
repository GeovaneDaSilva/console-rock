class AddSystemHuntsCategoryIdToHunts < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :system_hunts_category_id, :integer, index: true

    reversible do |dir|
      dir.up do
        Hunt.reset_column_information

        SystemHunts::Category.create(name: "Other") if SystemHunts::Category.none?

        other_category = SystemHunts::Category.first

        Hunt.where(system_hunt_feed: true).find_each do |hunt|
          hunt.update(system_hunts_category_id: other_category.id)
        end
      end
    end
  end
end
