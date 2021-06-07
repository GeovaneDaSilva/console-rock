class AddOptimizedTriageIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results,
              [:customer_id, :app_id, :detection_date],
              where: "incident_id IS NULL",
              order: { detection_date: :desc },
              name: "idx_apps_results_on_customer_id_app_id_detection_date_desc",
              algorithm: :concurrently
  end
end
