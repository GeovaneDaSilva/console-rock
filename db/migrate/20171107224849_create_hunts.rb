class CreateHunts < ActiveRecord::Migration[5.1]
  def change
    create_table :hunts do |t|
      t.string :name
      t.integer :group_id, null: false, index: true
      t.boolean :continious, default: false, null: false
      t.integer :revision, default: 1, null: false

      t.timestamps
    end
  end
end
