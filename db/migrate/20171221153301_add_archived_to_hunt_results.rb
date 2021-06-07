class AddArchivedToHuntResults < ActiveRecord::Migration[5.1]
  def change
    add_column :hunt_results, :archived, :boolean, default: false
  end
end
