class CreateAgentReleases < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :agent_releases, id: :string do |t|
      t.integer :period, null: false, default: 1800
      t.text :description, null: false
      t.integer :creator_id, null: false
      t.integer :agent_release_groups, array: true, default: [], null: false
      t.text :upload_ids, array: true, default: [], null: false

      t.timestamps
    end

    add_index :agent_releases, :creator_id, algorithm: :concurrently
  end
end
