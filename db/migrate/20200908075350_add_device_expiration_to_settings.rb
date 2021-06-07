class AddDeviceExpirationToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :device_expiration, :integer
  end
end
