class AddBillingEmailToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :emails, :text
  end
end
