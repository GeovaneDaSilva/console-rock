class AddDescriptionToHunts < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :description, :text
  end
end
