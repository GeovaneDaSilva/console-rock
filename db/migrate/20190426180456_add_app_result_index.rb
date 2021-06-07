class AddAppResultIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, [:device_id, :verdict], algorithm: :concurrently
  end
end
