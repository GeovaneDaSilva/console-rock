class RemoveSubLineItemsTable < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.down do
        add_index :sub_line_items, [:sub_line_itemable_type, :sub_line_itemable_id], name: :sub_line_itemable
        add_index :sub_line_items, :line_item_id
      end
    end

    drop_table :sub_line_items do |t|
      t.string :sub_line_itemable_type, null: false
      t.integer :sub_line_itemable_id, null: false
      t.integer :line_item_id, null: false

      t.timestamps
    end
  end
end
