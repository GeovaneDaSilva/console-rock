class CreateDevicesLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :devices_logs do |t|
      t.string :device_id, null: false, unique: true
      t.text :payload, null: false

      t.timestamps
    end
  end
end
