class AddUserSessionTimeoutToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :user_session_timeout, :integer
  end
end
