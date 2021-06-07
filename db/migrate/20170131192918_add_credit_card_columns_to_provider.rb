class AddCreditCardColumnsToProvider < ActiveRecord::Migration[5.0]
  def change
    add_column :providers, :card_type, :string
    add_column :providers, :card_masked_number, :string
    add_column :providers, :card_payment_method_token, :string
  end
end
