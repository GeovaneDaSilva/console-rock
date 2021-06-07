class CreateSystemHuntsCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :system_hunts_categories do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
