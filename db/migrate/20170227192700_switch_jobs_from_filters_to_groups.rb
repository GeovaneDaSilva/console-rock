class SwitchJobsFromFiltersToGroups < ActiveRecord::Migration[5.0]
  def change
    remove_column :jobs, :filters, :json

    add_column :jobs, :group_id, :integer
    add_index :jobs, :group_id
  end
end
