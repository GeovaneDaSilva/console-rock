class SwitchToMoreDetailedOsInfoForDevices < ActiveRecord::Migration[5.0]
  def change
    remove_column :devices, :os

    add_column :devices, :platform, :string
    add_column :devices, :family, :string
    add_column :devices, :version, :string
    add_column :devices, :edition, :string
    add_column :devices, :architecture, :string
    add_column :devices, :build, :string

    Device.reset_column_information
  end
end
