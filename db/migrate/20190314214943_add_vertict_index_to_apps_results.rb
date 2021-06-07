class AddVertictIndexToAppsResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, :verdict, algorithm: :concurrently
  end
end
