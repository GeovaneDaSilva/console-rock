class AddNewUsersSimpleViewDefaultToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :new_users_simple_view_default, :boolean
    change_column_default :settings, :new_users_simple_view_default, true

    Setting.reset_column_information
  end
end
