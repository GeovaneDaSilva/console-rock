class SimpleViewOffByDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :settings, :new_users_simple_view_default, from: true, to: false
  end
end
