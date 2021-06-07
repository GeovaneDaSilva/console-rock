class CreateLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items do |t|
      t.string :line_itemable_type, null: false
      t.string :line_itemable_id, null: false
      t.integer :amount_cents, default: 0, null: false
      t.string :amount_currency, default: "USD", null: false
      t.integer :charge_id, null: false

      t.timestamps
    end

    add_index :line_items, [:line_itemable_type, :line_itemable_id]
    add_index :line_items, :charge_id
  end
end
