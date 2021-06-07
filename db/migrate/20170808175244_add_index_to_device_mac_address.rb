class AddIndexToDeviceMacAddress < ActiveRecord::Migration[5.0]
  def change
    add_index :devices, :mac_address
  end
end
