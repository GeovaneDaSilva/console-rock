class CreateReportDevice < ActiveRecord::Migration[5.2]
  def change
    create_table :report_devices do |t|
      t.string :device_id, null: false
      t.ltree :account_path, null: false
      t.date :date
    end

    add_index :report_devices, :account_path
  end
end
