class AddEnableCustomerNotificationsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :enable_customer_notifications, :boolean
  end
end
