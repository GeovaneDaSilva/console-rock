class CreateAppsCounterCaches < ActiveRecord::Migration[5.2]
  def change
    create_table :apps_counter_caches do |t|
      t.ltree :account_path, null: false
      t.integer :app_id, null: false
      t.integer :count, null: false, default: 0
      t.integer :verdict, null: false
      t.string :device_id

      t.timestamps
    end

    add_index :apps_counter_caches, :account_path, using: :gist
    add_index :apps_counter_caches, :app_id
    add_index :apps_counter_caches, :device_id, where: "device_id != NULL"
  end
end
