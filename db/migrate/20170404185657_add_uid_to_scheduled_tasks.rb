class AddUidToScheduledTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :scheduled_tasks, :uid, :string

    add_index :scheduled_tasks, :uid
  end
end
