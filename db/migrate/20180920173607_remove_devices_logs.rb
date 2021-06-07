class RemoveDevicesLogs < ActiveRecord::Migration[5.2]
  def change
    drop_table :devices_logs do |t|
      t.string :device_id, null: false, unique: true
      t.text :payload, null: false

      t.timestamps
    end
  end
end
