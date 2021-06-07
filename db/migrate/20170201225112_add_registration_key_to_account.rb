class AddRegistrationKeyToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :registration_key, :string, null: false
    add_index :accounts, :registration_key
  end
end
