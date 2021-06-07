class AddDetailsToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :details, :jsonb
  end
end
