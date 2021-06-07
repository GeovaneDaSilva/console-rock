class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :query
      t.string :network
      t.string :os
      t.string :public_ip
      t.integer :query_fields, null: false, default: 0
      t.string :name, null: false
      t.integer :customer_id, null: false

      t.timestamps
    end

    add_index :groups, :customer_id
  end
end
