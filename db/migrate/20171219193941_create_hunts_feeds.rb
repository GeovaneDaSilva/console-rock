class CreateHuntsFeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :hunts_feeds do |t|
      t.string :keyword, default: "*", null: false
      t.integer :group_id, null: false, index: true

      t.timestamps
    end
  end
end
