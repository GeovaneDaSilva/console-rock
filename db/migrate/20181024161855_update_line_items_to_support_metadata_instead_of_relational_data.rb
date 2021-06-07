class UpdateLineItemsToSupportMetadataInsteadOfRelationalData < ActiveRecord::Migration[5.2]
  def change
    remove_index :line_items, column: ["line_itemable_type", "line_itemable_id"]

    safety_assured do
      remove_column :line_items, :line_itemable_type, :string, null: false
      remove_column :line_items, :line_itemable_id, :string, null: false
    end

    add_column :line_items, :meta, :jsonb
  end
end
