class CreateMsGraphCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :ms_graph_credentials do |t|
      t.string :tenant_id, :null => false
      t.integer :customer_id, :null => false
      t.string :display_name
      t.string :email
      t.jsonb :keys

      t.timestamps
    end

    add_index :ms_graph_credentials, :tenant_id, :unique => true
  end
end
