class AddCreditCardFieldsToCharges < ActiveRecord::Migration[5.0]
  def change
    add_column :charges, :card_type, :string
    add_column :charges, :card_masked_number, :string
    add_column :charges, :braintree_transaction_id, :string

    add_index :charges, :braintree_transaction_id
  end
end
