class AddRegistrationKeyToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :registration_key, :string

    add_index :accounts, :registration_key
  end
end
