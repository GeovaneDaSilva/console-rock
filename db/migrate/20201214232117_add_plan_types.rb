class AddPlanTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :plan_type, :string
  end
end
