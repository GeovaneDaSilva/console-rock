class RmIntercomColumns < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :accounts, :intercom_last_updated_at, :datetime
      remove_column :users, :disable_intercom, :datetime
    end
  end
end
