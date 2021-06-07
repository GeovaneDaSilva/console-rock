class RmSimpleViewColumns < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :settings, :new_users_simple_view_default, :boolean, default: false
      remove_column :user_roles, :simple_view, :boolean, default: false
    end
  end
end
