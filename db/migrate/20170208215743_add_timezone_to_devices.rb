class AddTimezoneToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :timezone, :string, default: "Etc/GMT+6"
  end
end
