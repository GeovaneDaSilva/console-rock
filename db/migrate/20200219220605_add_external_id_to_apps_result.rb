class AddExternalIdToAppsResult < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_results, :external_id, :string
  end
end
