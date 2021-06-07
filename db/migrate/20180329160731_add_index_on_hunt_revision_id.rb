class AddIndexOnHuntRevisionId < ActiveRecord::Migration[5.1]
  def change
    add_index :hunt_results, :hunt_revision_id
  end
end
