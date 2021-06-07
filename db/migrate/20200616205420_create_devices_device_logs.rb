class CreateDevicesDeviceLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :devices_device_logs do |t|
      t.string  :device_id, index: true
      t.integer :customer_id, index: true
      t.string  :upload_id, index: true

      t.timestamps
    end
  end
end
