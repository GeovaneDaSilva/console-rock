class AddMaxCpuUsageToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :max_cpu_usage, :integer
    change_column_default :settings, :max_cpu_usage, from: nil, to: 20

    reversible do |dir|
      dir.up do
        Setting.reset_column_information

        Setting.update_all(max_cpu_usage: 20)
      end
    end
  end
end
