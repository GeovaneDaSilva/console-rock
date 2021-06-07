class AddReportAgentErrorsToSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :report_agent_errors, :boolean, default: true, null: false
  end
end
