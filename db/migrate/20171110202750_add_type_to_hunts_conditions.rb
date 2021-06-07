class AddTypeToHuntsConditions < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts_conditions, :type, :string
  end
end
