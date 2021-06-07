class CreateApiKey < ActiveRecord::Migration[5.2]
  def change
    create_table :api_keys do |t|
      t.string :access_token, null: false
      t.string :refresh_token
      t.integer :account_id, null: false
      t.datetime :expiration, null: false
      t.text :permissions, array: true, default: []

      t.timestamps
    end

    add_index :api_keys, :access_token
    add_index :api_keys, :account_id
  end
end
