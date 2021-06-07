class CreateThreatsIndicatorDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :threats_indicator_devices do |t|
      t.integer :indicator_id, index: true, null: false
      t.string :device_id, index: true, null: false
      t.jsonb :details, null: false

      t.timestamps
    end
  end
end
