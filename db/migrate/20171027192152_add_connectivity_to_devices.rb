class AddConnectivityToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :connectivity, :integer, null: false, default: 0
  end
end
