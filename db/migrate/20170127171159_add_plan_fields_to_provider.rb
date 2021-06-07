class AddPlanFieldsToProvider < ActiveRecord::Migration[5.0]
  def change
    add_column :providers, :plan_id, :integer
    add_column :providers, :paid_thru, :date

    add_index :providers, :plan_id
  end
end
