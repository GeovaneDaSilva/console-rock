class AddMatchingToHunts < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :matching, :integer, null: false, default: 0
  end
end
