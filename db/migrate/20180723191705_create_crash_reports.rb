class CreateCrashReports < ActiveRecord::Migration[5.2]
  def change
    create_table :crash_reports do |t|
      t.string :device_id, index: true, null: false
      t.string :upload_id, index: true, null: false

      t.timestamps
    end
  end
end
