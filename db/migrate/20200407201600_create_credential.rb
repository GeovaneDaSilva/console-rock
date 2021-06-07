class CreateCredential < ActiveRecord::Migration[5.2]
  def change
    create_table :credentials do |t|
      t.string       :tenant_id
      t.integer      :customer_id
      t.string       :display_name
      t.string       :email
      t.datetime     :expiration
      t.jsonb        :keys
      t.string       :type

      t.timestamps
    end

    add_index :credentials, :tenant_id
    add_index :credentials, :type
    add_index :credentials, :expiration
  end
end
