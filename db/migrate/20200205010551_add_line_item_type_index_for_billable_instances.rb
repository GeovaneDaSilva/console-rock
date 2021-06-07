class AddLineItemTypeIndexForBillableInstances < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :billable_instances, :line_item_type, algorithm: :concurrently
  end
end
