class ChangeFieldsInReportBillableInstance < ActiveRecord::Migration[5.2]
  def up
     safety_assured do
       remove_column :report_billable_instances, :date

       add_column :report_billable_instances, :start_date, :date
       add_column :report_billable_instances, :end_date, :date
       add_column :report_billable_instances, :display_name, :string
     end
   end
   def down
     add_column :report_billable_instances, :date, :date

     remove_column :report_billable_instances, :start_date
     remove_column :report_billable_instances, :end_date
   end
end
