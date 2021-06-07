class AddColumnsToAccount < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :accounts, :tenant_id, :string
    add_column :accounts, :ms_graph_credential_id, :integer

    add_index :accounts, :tenant_id, algorithm: :concurrently
  end
end
