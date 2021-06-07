class DowncaseExistingDeviceIds < ActiveRecord::Migration[5.0]
  def change
    Device.find_each do |device|
      device.id = device.id
      device.save
    end
  end
end
