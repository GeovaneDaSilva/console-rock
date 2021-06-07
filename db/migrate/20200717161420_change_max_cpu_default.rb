class ChangeMaxCpuDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :settings, :max_cpu_usage, from: 4, to: 2
  end
end
