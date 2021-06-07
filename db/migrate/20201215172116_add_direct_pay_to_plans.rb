class AddDirectPayToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :direct_pay, :boolean
  end
end
