class AddGroupAttributesCacheKeyToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :group_attributes_cache_key, :datetime
    Device.update_all("group_attributes_cache_key = updated_at")
  end
end
