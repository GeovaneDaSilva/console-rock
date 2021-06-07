class AddFeaturedAttributesToAppsIncidentResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_incident_responses, :featured_attributes, :text, array: true
    change_column_default :apps_incident_responses, :featured_attributes, from: nil, to: []
  end
end
