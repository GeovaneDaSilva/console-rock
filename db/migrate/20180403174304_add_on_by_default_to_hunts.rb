class AddOnByDefaultToHunts < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :on_by_default, :boolean
    change_column_default :hunts, :on_by_default, false
  end
end
