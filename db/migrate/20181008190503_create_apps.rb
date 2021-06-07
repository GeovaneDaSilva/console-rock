class CreateApps < ActiveRecord::Migration[5.2]
  def change
    create_table :apps do |t|
      t.text :title
      t.text :description
      t.string :upload_id, index: true, null: false
      t.integer :indicator, null: false, default: 0

      t.timestamps
    end
  end
end
