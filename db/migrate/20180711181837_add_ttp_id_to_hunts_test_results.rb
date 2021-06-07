class AddTTPIdToHuntsTestResults < ActiveRecord::Migration[5.2]
  def change
    add_column :hunts_test_results, :ttp_id, :string, index: true
  end
end
