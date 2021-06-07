class IndexEgressIpIp < ActiveRecord::Migration[5.0]
  def change
    add_index :egress_ips, :ip
  end
end
