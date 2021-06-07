class AddDateTimezoneToScheduledTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :scheduled_tasks, :date_timezone, :string, null: false, default: "UTC"
  end
end
