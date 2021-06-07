class RemoveUnusedIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :apps_results, name: "index_apps_results_on_app_id"
    remove_index :apps_results, name: "index_apps_results_on_device_id"
    remove_index :apps_results, name: "index_apps_results_on_value"
    remove_index :devices_queued_hunts, name: "index_devices_queued_hunts_on_hunt_id"
    remove_index :hunt_results, name: "index_hunt_results_on_hunt_id"
  end
end
