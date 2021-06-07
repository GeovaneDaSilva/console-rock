class AddTagsToHuntResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :hunt_results, :tags, :text, array: true
    change_column_default :hunt_results, :tags, from: nil, to: []

    add_index :hunt_results, :tags, using: :gin, algorithm: :concurrently
  end
end
