class AddIncidentToAppsResults < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_results, :incident, :boolean
  end
end
