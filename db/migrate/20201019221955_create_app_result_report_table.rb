class CreateAppResultReportTable < ActiveRecord::Migration[5.2]
  def change
    create_table :report_app_results do |t|
      t.integer :app_id, null: false
      t.ltree :account_path, null: false
      t.date :date
      t.integer :count, null: false
      t.integer :verdict
      t.jsonb :details
    end

    add_index :report_app_results, :account_path
    add_index :report_app_results, :app_id
    add_index :report_app_results, :verdict
    add_index :report_app_results, :date
  end
end
