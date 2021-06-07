class RmOffice365Mailboxes < ActiveRecord::Migration[5.2]
  def change
    remove_index :office365_mailboxes, :account_path
    remove_index :office365_mailboxes, :external_id

    drop_table :office365_mailboxes do |t|
      t.ltree :account_path, null: false
      t.jsonb :details
      t.string :external_id, null: false

      t.timestamps
    end
  end
end
