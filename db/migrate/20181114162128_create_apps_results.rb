class CreateAppsResults < ActiveRecord::Migration[5.2]
  def change
    create_table :apps_results do |t|
      t.integer :app_id, index: true, null: false
      t.string :device_id, index: true, null: false
      t.integer :verdict, default: 0, null: false
      t.datetime :detection_date, null: false
      t.text :value, null: false
      t.string :value_type, null: false
      t.jsonb :details, null: false

      t.timestamps
    end

    add_index :apps_results, [:value, :value_type]
  end
end
