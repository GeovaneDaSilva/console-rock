class AddSessionTimeoutToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :session_timeout, :integer
  end
end
