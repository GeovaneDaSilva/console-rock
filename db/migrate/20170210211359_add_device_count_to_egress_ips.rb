class AddDeviceCountToEgressIps < ActiveRecord::Migration[5.0]
  def change
    add_column :egress_ips, :devices_count, :integer, default: 0
  end
end
