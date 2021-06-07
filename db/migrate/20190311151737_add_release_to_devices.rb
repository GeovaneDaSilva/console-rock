class AddReleaseToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :release, :string
  end
end
