class AddTypeIndexToAppResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, :type, algorithm: :concurrently
  end
end
