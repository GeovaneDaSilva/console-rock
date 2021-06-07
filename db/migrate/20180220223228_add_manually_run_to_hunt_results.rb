class AddManuallyRunToHuntResults < ActiveRecord::Migration[5.1]
  def change
    add_column :hunt_results, :manually_run, :boolean, default: false
  end
end
