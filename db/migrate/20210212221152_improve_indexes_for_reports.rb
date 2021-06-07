class ImproveIndexesForReports < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps, :disabled, algorithm: :concurrently
    add_index :apps, :discreet, algorithm: :concurrently
    add_index :apps_incidents, :state, algorithm: :concurrently
    add_index :apps_incidents, :created_at, algorithm: :concurrently
    add_index :apps_results, :detection_date, algorithm: :concurrently
    add_index :billable_instances, :active, where: 'active = TRUE', algorithm: :concurrently
    add_index :billable_instances, :updated_at, algorithm: :concurrently
    add_index :devices, :marked_for_deletion, algorithm: :concurrently
    add_index :devices_connectivity_logs, :connected_at, algorithm: :concurrently

    reversible do |dir|
      dir.up do
        safety_assured do
          execute "CREATE INDEX CONCURRENTLY idx_on_apps_results_details_attributes_country ON apps_results ((details -> 'attributes' ->> 'country')) WHERE details -> 'attributes' ->> 'country' IS NOT NULL"
          execute "CREATE INDEX CONCURRENTLY idx_on_apps_results_details_attributes_user_principalName ON apps_results ((details -> 'attributes' -> 'user' ->> 'principalName')) WHERE details -> 'attributes' -> 'user' ->> 'principalName' IS NOT NULL"
        end
      end

      dir.down do
        safety_assured do
          execute "DROP INDEX CONCURRENTLY idx_on_apps_results_details_attributes_country"
          execute "DROP INDEX CONCURRENTLY idx_on_apps_results_details_attributes_user_principalName"
        end
      end
    end
  end
end
