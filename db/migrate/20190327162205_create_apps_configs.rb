class CreateAppsConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :apps_configs do |t|
      t.integer :app_id
      t.json :config
      t.uuid :device_id
      t.integer :account_id
      t.string :type

      t.timestamps
    end

    add_index :apps_configs, :app_id
    add_index :apps_configs, [:type, :device_id]
    add_index :apps_configs, [:type, :account_id]
  end
end
