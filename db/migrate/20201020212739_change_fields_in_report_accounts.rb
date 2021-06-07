class ChangeFieldsInReportAccounts < ActiveRecord::Migration[5.2]
   def change
     add_column :report_accounts, :type, :string
     add_column :report_accounts, :start_date, :date
     add_column :report_accounts, :end_date, :date
   end
end
