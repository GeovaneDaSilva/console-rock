class CreateAppsIncidents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :apps_incidents do |t|
      t.text :title
      t.text :description
      t.text :remediation
      t.ltree :account_path, null: false
      t.integer :state, null: false, default: 0
      t.integer :creator_id, null: false
      t.integer :resolver_id
      t.datetime :resolved_at
      t.datetime :published_at

      t.timestamps
    end

    add_index :apps_incidents, :account_path, using: :gist, algorithm: :concurrently
    add_index :apps_incidents, :creator_id, algorithm: :concurrently
    add_index :apps_incidents, :resolver_id, algorithm: :concurrently
  end
end
