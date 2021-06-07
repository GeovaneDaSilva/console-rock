class AddDevicesCountToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :devices_count, :integer, default: 0
  end
end
