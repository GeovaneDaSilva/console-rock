class AddSuperAdminToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :super_admin, :boolean, default: false, null: false
  end
end
