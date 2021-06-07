class CreateAppsIncidentResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :apps_incident_responses do |t|
      t.text :note_body
      t.text :remediation_body

      t.timestamps
    end
  end
end
