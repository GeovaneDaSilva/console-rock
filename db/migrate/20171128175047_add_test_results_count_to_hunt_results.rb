class AddTestResultsCountToHuntResults < ActiveRecord::Migration[5.1]
  def change
    add_column :hunt_results, :test_results_count, :integer, null: false, default: 0
  end
end
