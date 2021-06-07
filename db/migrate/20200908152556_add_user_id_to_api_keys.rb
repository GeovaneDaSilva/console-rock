class AddUserIdToApiKeys < ActiveRecord::Migration[5.2]
  def change
    add_column :api_keys, :user_id, :integer
  end
end
