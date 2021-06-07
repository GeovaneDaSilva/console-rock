require "csv"

class CreateTTPs < ActiveRecord::Migration[5.2]
  def change
    create_table :ttps, id: :string do |t|
      t.string :tactic, null: false
      t.string :technique, null: false
      t.text :description, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
