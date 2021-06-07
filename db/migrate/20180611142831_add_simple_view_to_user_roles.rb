class AddSimpleViewToUserRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :user_roles, :simple_view, :boolean
    change_column_default :user_roles, :simple_view, false
  end
end
