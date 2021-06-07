class AddIncidentIdToAppsResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :apps_results, :incident_id, :integer
    add_index :apps_results, :incident_id, algorithm: :concurrently
  end
end
