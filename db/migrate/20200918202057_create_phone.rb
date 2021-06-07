class CreatePhone < ActiveRecord::Migration[5.2]
  def change
    create_table :phones do |t|
      t.integer   :account_id
      t.text      :numbers, array: true, default: []
      t.integer   :category
    end

    add_index :phones, [:account_id, :category]
  end
end
