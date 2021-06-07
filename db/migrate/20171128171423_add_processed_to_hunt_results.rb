class AddProcessedToHuntResults < ActiveRecord::Migration[5.1]
  def change
    add_column :hunt_results, :processed, :boolean, default: false
  end
end
