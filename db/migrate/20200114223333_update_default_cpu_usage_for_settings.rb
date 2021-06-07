class UpdateDefaultCpuUsageForSettings < ActiveRecord::Migration[5.2]
  def change
    change_column_default :settings, :max_cpu_usage, from: 10, to: 4
  end
end
