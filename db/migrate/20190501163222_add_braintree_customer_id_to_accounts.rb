class AddBraintreeCustomerIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :braintree_customer_id, :string
  end
end
