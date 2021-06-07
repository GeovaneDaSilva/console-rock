require_relative '20191106160710_create_devices_inventories'

class RemoveDevicesInventoryTable < ActiveRecord::Migration[5.2]
  def change
    revert CreateDevicesInventories
  end
end
