class CreateReportAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :report_accounts do |t|
      t.integer :account_id
      t.ltree :account_path
      t.string :name
    end
  end
end
