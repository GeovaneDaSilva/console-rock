class AddDeviceAndAppIdIndexToAppResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, [:app_id, :device_id], algorithm: :concurrently
  end
end
