class AddDeviceIdIndexToAppsResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, :device_id, where: "device_id != NULL", algorithm: :concurrently
  end
end
