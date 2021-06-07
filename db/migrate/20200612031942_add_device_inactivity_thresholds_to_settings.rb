class AddDeviceInactivityThresholdsToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :device_inactivity_thresholds, :jsonb
  end
end
