class AddLastConnectedAtToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :last_connected_at, :datetime

    Device.reset_column_information

    Device.find_each do |device|
      device.update(last_connected_at: device.connectivity_updated_at)
    end
  end
end
