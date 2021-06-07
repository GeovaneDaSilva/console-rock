class AddIncidentReportEmailLastSentToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :incident_report_email_last_sent, :datetime
  end
end
