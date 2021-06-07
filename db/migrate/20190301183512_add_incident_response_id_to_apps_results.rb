class AddIncidentResponseIdToAppsResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :apps_results, :incident_response_id, :integer

    add_index :apps_results, :incident_response_id, algorithm: :concurrently
  end
end
