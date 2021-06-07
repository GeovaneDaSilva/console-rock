class CreateHuntsConditions < ActiveRecord::Migration[5.1]
  def change
    create_table :hunts_conditions do |t|
      t.integer :test_id, index: true, null: false
      t.integer :operator, null: false, default: 0
      t.string :value
      t.integer :order, null: false, default: 1

      t.timestamps
    end
  end
end
