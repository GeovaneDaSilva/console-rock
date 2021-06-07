class CreateTextSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :text_searches do |t|
      t.references :searchable, polymorphic: true, index: true, type: :string
      t.text :blob
      t.text :auto_complete_description
      t.integer :account_id, index: true

      t.timestamps
    end
  end
end
