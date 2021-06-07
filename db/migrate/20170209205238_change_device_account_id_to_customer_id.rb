class ChangeDeviceAccountIdToCustomerId < ActiveRecord::Migration[5.0]
  def change
    rename_column :devices, :account_id, :customer_id
  end
end
