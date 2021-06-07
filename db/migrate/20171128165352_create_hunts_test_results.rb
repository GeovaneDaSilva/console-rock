class CreateHuntsTestResults < ActiveRecord::Migration[5.1]
  def change
    create_table :hunts_test_results do |t|
      t.integer :result, default: 0, null: false
      t.integer :test_id, null: false, index: true
      t.integer :hunt_result_id, null: false, index: true
      t.jsonb :details

      t.timestamps
    end
  end
end
