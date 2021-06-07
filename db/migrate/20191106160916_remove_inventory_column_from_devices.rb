class RemoveInventoryColumnFromDevices < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :devices, :inventory, :jsonb
    end
  end
end
