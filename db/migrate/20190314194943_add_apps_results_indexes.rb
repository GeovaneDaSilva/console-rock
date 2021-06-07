class AddAppsResultsIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, :value, algorithm: :concurrently
    add_index :apps_results, :incident, algorithm: :concurrently
  end
end
