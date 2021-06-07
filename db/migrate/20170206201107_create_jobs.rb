class CreateJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :jobs do |t|
      t.integer :account_id, null: false
      t.integer :script, null: false
      t.datetime :date
      t.integer :frequency, null: false, default: 0
      t.string :name
      t.integer :status, null: false, default: 0
      t.json :filters

      t.timestamps
    end

    add_index :jobs, :account_id
  end
end
