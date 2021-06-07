class CreateReportIncidents < ActiveRecord::Migration[5.2]
  def change
    create_table :report_incidents do |t|
      t.ltree :account_path
      t.integer :state
      t.datetime :create_date
      t.datetime :close_date
      t.jsonb :details
    end

    add_index :report_incidents, :account_path
  end
end
