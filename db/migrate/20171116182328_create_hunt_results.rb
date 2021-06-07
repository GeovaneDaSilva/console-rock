class CreateHuntResults < ActiveRecord::Migration[5.1]
  def change
    create_table :hunt_results do |t|
      t.integer :hunt_id, index: true
      t.integer :hunt_revision, null: false, default: 1
      t.string :device_id, null: false, index: true
      t.string :upload_id, null: false, index: true

      t.timestamps
    end
  end
end
