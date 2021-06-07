class CreateEgressIps < ActiveRecord::Migration[5.0]
  def change
    create_table :egress_ips do |t|
      t.integer :customer_id, null: false
      t.string :ip, null: false
      t.float :latitude, default: 0
      t.float :longitude, default: 0

      t.timestamps
    end
  end
end
