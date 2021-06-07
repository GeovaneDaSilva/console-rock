class AddResultToHuntResults < ActiveRecord::Migration[5.1]
  def change
    add_column :hunt_results, :result, :integer, null: false, default: 0
  end
end
