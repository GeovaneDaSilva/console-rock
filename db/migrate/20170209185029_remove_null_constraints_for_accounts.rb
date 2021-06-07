class RemoveNullConstraintsForAccounts < ActiveRecord::Migration[5.0]
  def change
    change_column :accounts, :paid_thru, :date, null: true
  end
end
