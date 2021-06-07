class RenamePlansMaxMonitoredDevicesToIncludedDevices < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :plans, :max_monitored_devices, :included_devices
    end
  end
end
