class SetUserTimeoutDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :session_timeout, 14400
  end
end
