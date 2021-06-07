class AddTypeToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :type, :string

    App.reset_column_information
    App.update_all(type: "Apps::DeviceApp")
  end
end
