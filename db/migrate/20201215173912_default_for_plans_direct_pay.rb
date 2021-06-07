class DefaultForPlansDirectPay < ActiveRecord::Migration[5.2]
  def change
    change_column_default :plans, :direct_pay, true
  end
end
