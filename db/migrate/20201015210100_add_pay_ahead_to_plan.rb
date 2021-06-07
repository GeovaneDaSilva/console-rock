class AddPayAheadToPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :payment_plan, :integer
  end
end
