class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.integer   :account_id
      t.text      :emails, array: true, default: []
      t.integer   :category
    end

    add_index :emails, [:account_id, :category]
  end
end
