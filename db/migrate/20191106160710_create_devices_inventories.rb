class CreateDevicesInventories < ActiveRecord::Migration[5.2]
  def change
    create_table :devices_inventories do |t|
      t.string :device_id
      t.jsonb :data

      t.timestamps
    end

    add_index :devices_inventories, :device_id
  end
end
