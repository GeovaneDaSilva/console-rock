class AddDefenderHealthStatusToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :defender_health_status, :integer
    change_column_default :devices, :defender_health_status, from: nil, to: 0

    reversible do |dir|
      dir.up do
        Device.reset_column_information
        Device.update_all(defender_health_status: 0)
      end
    end
  end
end
