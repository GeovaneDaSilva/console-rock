class AddHideBillingToPlan < ActiveRecord::Migration[5.2]
  def up
    add_column :plans, :hide_billing, :boolean
    change_column_default :plans, :hide_billing, false
  end
  def down
    remove_column :plans, :hide_billing
  end
end
