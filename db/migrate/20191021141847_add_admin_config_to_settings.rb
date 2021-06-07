class AddAdminConfigToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :admin_config, :jsonb
    change_column_default :settings, :admin_config, from: nil, to: {}

    Setting.reset_column_information
    Setting.update_all(admin_config: {})
  end
end
