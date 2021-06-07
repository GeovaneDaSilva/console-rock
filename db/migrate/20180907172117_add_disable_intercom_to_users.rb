class AddDisableIntercomToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :disable_intercom, :boolean
  end
end
