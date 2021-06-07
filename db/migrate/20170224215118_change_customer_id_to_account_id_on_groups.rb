class ChangeCustomerIdToAccountIdOnGroups < ActiveRecord::Migration[5.0]
  def change
    rename_column :groups, :customer_id, :account_id
  end
end
