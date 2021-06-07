class MoveUserRolesAwayFromPolymorphic < ActiveRecord::Migration[5.0]
  def change
    remove_index :user_roles, [:roleable_type, :roleable_id]

    remove_column :user_roles, :roleable_type
    rename_column :user_roles, :roleable_id, :account_id

    add_index :user_roles, :account_id
  end
end
