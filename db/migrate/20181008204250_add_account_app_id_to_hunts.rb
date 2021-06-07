class AddAccountAppIdToHunts < ActiveRecord::Migration[5.2]
  def change
    add_column :hunts, :account_app_id, :integer, index: true
  end
end
