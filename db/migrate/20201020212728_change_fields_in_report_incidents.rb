class ChangeFieldsInReportIncidents < ActiveRecord::Migration[5.2]
  def change
    add_column :report_incidents, :incident_id, :integer
  end
end
