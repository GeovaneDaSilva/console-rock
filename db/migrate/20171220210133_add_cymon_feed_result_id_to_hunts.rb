class AddCymonFeedResultIdToHunts < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :cymon_feed_result_id, :string, index: true
  end
end
