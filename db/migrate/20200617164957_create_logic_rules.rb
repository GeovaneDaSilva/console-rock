class CreateLogicRules < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :logic_rules do |t|
      t.integer       :app_id
      t.integer       :user_id
      t.jsonb         :rules, null: false
      t.integer       :account_id
      t.string        :account_path
      t.string        :actions, array: true, default: []
      t.integer       :dependencies, array: true, default: []

      t.timestamps
    end

    add_index :logic_rules, :app_id
    add_index :logic_rules, :user_id
    add_index :logic_rules, :account_path, algorithm: :concurrently
    add_index :logic_rules, %i[app_id account_id]
  end
end
