class AddItemTypeToLineItem < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items, :item_type, :integer, null: false
  end
end
