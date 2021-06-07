class CreateDevicesConnectivityLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :devices_connectivity_logs do |t|
      t.string :device_id, index: true, null: false
      t.datetime :connected_at, null: false
      t.datetime :disconnected_at, null: false
      t.integer :duration, default: 0, null: false

      t.timestamps
    end
  end
end
