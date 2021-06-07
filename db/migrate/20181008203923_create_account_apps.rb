class CreateAccountApps < ActiveRecord::Migration[5.2]
  def change
    create_table :account_apps do |t|
      t.integer :account_id, index: true
      t.integer :app_id, index: true
      t.datetime :disabled_at
      t.datetime :enabled_at

      t.timestamps
    end
  end
end
