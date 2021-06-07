class ChangeAppsConfigsDeviceIdToBeString < ActiveRecord::Migration[5.2]
  def change
    safety_assured do # Dancing with the devil in the pale moonlight
      change_column :apps_configs, :device_id, :string
    end
  end
end
