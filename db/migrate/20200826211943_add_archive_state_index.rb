class AddArchiveStateIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :apps_results, :archive_state, algorithm: :concurrently
  end
end
