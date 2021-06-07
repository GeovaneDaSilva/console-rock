class AddOsAndIpv4SubnetMaskToDevice < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :os, :string, default: "Unknown", null: false
    add_column :devices, :ipv4_subnet_mask, :string, default: "255.255.255.0", null: false
  end
end
