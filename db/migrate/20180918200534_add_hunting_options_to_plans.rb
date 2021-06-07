class AddHuntingOptionsToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :advanced_hunting, :boolean
    add_column :plans, :continuous_hunting, :boolean

    change_column_default :plans, :advanced_hunting, from: nil, to: true
    change_column_default :plans, :continuous_hunting, from: nil, to: true
  end
end
