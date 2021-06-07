class CreateReportUsageTable < ActiveRecord::Migration[5.2]
  def change
    create_table :report_usage_data do |t|
      t.integer   :device_count
      t.integer   :firewall_count
      t.integer   :mailbox_count
      t.integer   :account_id
      t.ltree     :account_path
      t.date      :date
      t.integer   :plan_id

      t.timestamps
    end
  end
end
