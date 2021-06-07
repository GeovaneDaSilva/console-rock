class AddDisabledToHunts < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :disabled, :boolean, default: false
  end
end
