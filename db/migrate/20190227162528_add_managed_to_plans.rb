class AddManagedToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :managed, :boolean
  end
end
