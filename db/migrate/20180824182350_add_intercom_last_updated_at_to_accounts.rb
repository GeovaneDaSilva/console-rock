class AddIntercomLastUpdatedAtToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :intercom_last_updated_at, :datetime
    change_column_default :accounts, :intercom_last_updated_at, from: nil, to: DateTime.parse("1918-08-24 19:34:07")

    Account.reset_column_information
    Account.update_all(intercom_last_updated_at: 100.years.ago)
  end
end
