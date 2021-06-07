class CreateOffice365Mailboxes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :office365_mailboxes do |t|
      t.ltree :account_path, null: false
      t.jsonb :details
      t.string :external_id, null: false

      t.timestamps
    end

    add_index :office365_mailboxes, :account_path, using: :gist, algorithm: :concurrently
    add_index :office365_mailboxes, :external_id, algorithm: :concurrently
  end
end
