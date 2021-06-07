class CreateProviders < ActiveRecord::Migration[5.0]
  def change
    create_table :providers do |t|
      t.string :name, null: false
      t.ltree :path

      t.timestamps
    end

    add_index :providers, :path, using: :gist
  end
end
