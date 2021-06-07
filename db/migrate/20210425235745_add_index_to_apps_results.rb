class AddIndexToAppsResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index(:apps_results,
              [:detection_date, :app_id, :incident_id],
              order: { detection_date: :desc },
              algorithm: :concurrently,
              name: "idx_on_apps_results_improve_triages_show_speed")
  end
end
