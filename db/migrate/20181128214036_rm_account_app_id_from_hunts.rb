class RmAccountAppIdFromHunts < ActiveRecord::Migration[5.2]
  def change
    Hunt.where.not(account_app_id: nil).destroy_all

    safety_assured do
      remove_column :hunts, :account_app_id, :integer
    end
  end
end
