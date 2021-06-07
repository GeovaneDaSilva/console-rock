class AddUuidToDevices < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :devices, :uuid, :text

    reversible do |dir|
      dir.up do
        Device.reset_column_information

        Device.find_each do |device|
          device.update_column(
            :uuid,
            Digest::MD5.hexdigest([device.fingerprint, device.customer.license_key].join("-"))
          )
        end
      end
    end

    add_index :devices, :uuid, algorithm: :concurrently, unique: false
  end
end
