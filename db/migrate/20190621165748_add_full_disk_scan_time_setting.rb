class AddFullDiskScanTimeSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :full_disk_scan_time, :integer
    change_column_default :settings, :full_disk_scan_time, from: nil, to: 1

    reversible do |dir|
      dir.up do
        Setting.reset_column_information

        Setting.update_all(full_disk_scan_time: 1)
      end
    end
  end
end
