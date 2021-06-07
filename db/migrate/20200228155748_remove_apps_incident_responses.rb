class RemoveAppsIncidentResponses < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      drop_table :apps_incident_responses
      remove_column :apps_results, :incident_response_id
    end
  end
end
