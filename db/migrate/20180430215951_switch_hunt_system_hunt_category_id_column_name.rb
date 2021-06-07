class SwitchHuntSystemHuntCategoryIdColumnName < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      rename_column :hunts, :system_hunts_category_id, :category_id
    end
  end
end
