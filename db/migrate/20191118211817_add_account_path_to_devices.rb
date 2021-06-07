class AddAccountPathToDevices < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :devices, :account_path, :ltree

    add_index :devices, :account_path, using: :gist, algorithm: :concurrently
  end
end
