class AddAccountIdToCharges < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    change_column_null :charges, :provider_id, true

    add_column :charges, :account_id, :integer
    add_index :charges, :account_id, algorithm: :concurrently

    reversible do |dir|
      dir.up do
        Charge.update_all("account_id = provider_id")
      end
    end
  end
end
