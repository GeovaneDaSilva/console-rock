class AddDefaultDeviceDetails < ActiveRecord::Migration[5.2]
  def change
    change_column_default :devices, :details, {}
  end
end
