class AddConnectivityUpdatedAtToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :connectivity_updated_at, :datetime, default: DateTime.parse("2008-12-05 00:03:27")
  end
end
