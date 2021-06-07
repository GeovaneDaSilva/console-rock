class RemoveDevicesCountFromAccounts < ActiveRecord::Migration[5.2]
  def up
    safety_assured { remove_column :accounts, :devices_count, :integer }
  end

  def down
    add_column :accounts, :devices_count, :integer
    change_column_default :accounts, :devices_count, from: nil, to: 0

    Customer.find_each do |customer|
      customer.update(devices_count: Device.where(account_path: customer.path).count)
    end
  end
end
