class AddAccountIdToCredentials < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :credentials, :account_id, :integer

    add_index :credentials, :account_id, algorithm: :concurrently
  end
end
