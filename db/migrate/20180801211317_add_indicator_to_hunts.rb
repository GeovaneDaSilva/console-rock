class AddIndicatorToHunts < ActiveRecord::Migration[5.2]
  def change
    add_column :hunts, :indicator, :integer

    change_column_default :hunts, :indicator, from: nil, to: 0
  end
end
