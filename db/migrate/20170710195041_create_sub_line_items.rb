class CreateSubLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :sub_line_items do |t|
      t.string :sub_line_itemable_type, null: false
      t.integer :sub_line_itemable_id, null: false
      t.integer :line_item_id, null: false

      t.timestamps
    end

    add_index :sub_line_items, [:sub_line_itemable_type, :sub_line_itemable_id], name: :sub_line_itemable
    add_index :sub_line_items, :line_item_id
  end
end
