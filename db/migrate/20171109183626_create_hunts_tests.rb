class CreateHuntsTests < ActiveRecord::Migration[5.1]
  def change
    create_table :hunts_tests do |t|
      t.string :type
      t.integer :revision, null: false, default: 0, index: true
      t.integer :hunt_id, null: false, index: true

      t.timestamps
    end
  end
end
