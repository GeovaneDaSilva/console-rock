class AddNetworkToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :network, :string

    Device.reset_column_information

    Device.all.each(&:save)
  end
end
