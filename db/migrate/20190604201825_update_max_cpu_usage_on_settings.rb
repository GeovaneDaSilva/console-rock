class UpdateMaxCpuUsageOnSettings < ActiveRecord::Migration[5.2]
  def change
    change_column_default :settings, :max_cpu_usage, from: 20, to: 10

    Setting.where(max_cpu_usage: 20).update_all(max_cpu_usage: 10)
  end
end
