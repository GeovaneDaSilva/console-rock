class AddEgressIpIdToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :egress_ip_id, :integer
    add_index :devices, :egress_ip_id
  end
end
