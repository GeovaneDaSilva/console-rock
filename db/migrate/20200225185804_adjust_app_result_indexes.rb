class AdjustAppResultIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    remove_index :apps_results, name: "index_apps_results_on_app_id"
    add_index :apps_results, :external_id, algorithm: :concurrently
  end

  def down
    add_index :app_results, :app_id, algorithm: :concurrently
  end
end
