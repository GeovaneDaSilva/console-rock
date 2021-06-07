class AddAdminRoleToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :admin_role, :integer, default: 0, null: false
  end
end
