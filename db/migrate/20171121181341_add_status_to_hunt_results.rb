class AddStatusToHuntResults < ActiveRecord::Migration[5.1]
  def change
    add_column :hunt_results, :status, :integer, null: false, default: 0
  end
end
