class AddOnDemandToHunts < ActiveRecord::Migration[5.2]
  def change
    add_column :hunts, :on_demand, :boolean
  end
end
