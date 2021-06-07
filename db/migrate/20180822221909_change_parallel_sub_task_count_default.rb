class ChangeParallelSubTaskCountDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :settings, :parallel_sub_task_count, from: 2, to: 10
  end
end
