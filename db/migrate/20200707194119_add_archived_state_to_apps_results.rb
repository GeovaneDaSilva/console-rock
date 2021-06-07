class AddArchivedStateToAppsResults < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_results, :archive_state, :integer
  end
end
