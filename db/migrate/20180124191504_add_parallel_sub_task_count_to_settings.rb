class AddParallelSubTaskCountToSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :parallel_sub_task_count, :integer, null: false, default: 2
  end
end
