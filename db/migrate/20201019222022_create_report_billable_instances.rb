class CreateReportBillableInstances < ActiveRecord::Migration[5.2]
  def change
    create_table :report_billable_instances do |t|
      t.integer :billable_instance_id
      t.date :date
      t.integer :line_item_type
    end
  end
end
