class AddInventoryUploadIdToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :inventory_upload_id, :string
  end
end
