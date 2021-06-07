class CreateHuntsCymonFeedResults < ActiveRecord::Migration[5.1]
  def change
    create_table :hunts_cymon_feed_results, id: :string do |t|
      t.integer :feed_id, null: false, index: true
      t.string :provider
      t.string :title
      t.text :description
      t.datetime :timestamp
      t.json :ioc

      t.timestamps
    end
  end
end
