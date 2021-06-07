class AddReportIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :report_accounts, :account_id, algorithm: :concurrently
    add_index :report_accounts, :account_path, algorithm: :concurrently
    add_index :report_billable_instances, :billable_instance_id, algorithm: :concurrently
    add_index :report_devices, :device_id, algorithm: :concurrently
    add_index :report_incidents, :incident_id, algorithm: :concurrently
  end
end
