class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices, id: :string do |t|
      t.integer :account_id
      t.string :hostname
      t.string :ipv4_address
      t.string :mac_address
      t.string :username
      t.string :fingerprint

      t.timestamps
    end

    add_index :devices, :account_id
  end
end
