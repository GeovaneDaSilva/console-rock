class AddIndexOnAppsResultsDetailsType < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, "(details->>'type')", name: "index_apps_results_details_type", algorithm: :concurrently
  end
end
