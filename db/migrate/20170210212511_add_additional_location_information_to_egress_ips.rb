class AddAdditionalLocationInformationToEgressIps < ActiveRecord::Migration[5.0]
  def change
    add_column :egress_ips, :city, :string
    add_column :egress_ips, :state, :string
    add_column :egress_ips, :country, :string
  end
end
