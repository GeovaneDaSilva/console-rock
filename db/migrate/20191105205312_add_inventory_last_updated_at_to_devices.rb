class AddInventoryLastUpdatedAtToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :inventory_last_updated_at, :datetime
  end
end
