class AddIndexForFeedResultId < ActiveRecord::Migration[5.1]
  def change
    add_index :hunts, :feed_result_id
  end
end
