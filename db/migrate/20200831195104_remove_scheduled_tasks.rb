class RemoveScheduledTasks < ActiveRecord::Migration[5.2]
  def change
    drop_table :scheduled_tasks
  end
end
