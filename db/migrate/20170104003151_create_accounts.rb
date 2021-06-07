class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.integer :provider_id, null: false

      t.timestamps
    end

    add_index :accounts, :provider_id
  end
end
