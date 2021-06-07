class ChangeJobAccountIdToCustomerId < ActiveRecord::Migration[5.0]
  def change
    rename_column :jobs, :account_id, :customer_id
  end
end
