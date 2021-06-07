class CreateBillableInstances < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :billable_instances do |t|
      t.ltree :account_path, null: false
      t.jsonb :details, default: {}
      t.string :external_id, null: false
      t.integer :line_item_type, null: false

      t.timestamps
    end

    add_index :billable_instances, :account_path, using: :gist, algorithm: :concurrently
    add_index :billable_instances, :external_id, algorithm: :concurrently
  end
end
