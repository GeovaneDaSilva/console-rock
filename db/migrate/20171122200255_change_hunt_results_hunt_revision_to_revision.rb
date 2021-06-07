class ChangeHuntResultsHuntRevisionToRevision < ActiveRecord::Migration[5.1]
  def change
    rename_column :hunt_results, :hunt_revision, :revision
  end
end
