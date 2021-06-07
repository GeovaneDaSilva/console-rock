class CreateDevicesQueuedHunts < ActiveRecord::Migration[5.2]
  def change
    create_table :devices_queued_hunts do |t|
      t.string :device_id
      t.integer :hunt_id

      t.timestamps
    end

    add_index :devices_queued_hunts, :device_id
    add_index :devices_queued_hunts, :hunt_id
    add_index :devices_queued_hunts, [:hunt_id, :device_id], unique: true
  end
end
