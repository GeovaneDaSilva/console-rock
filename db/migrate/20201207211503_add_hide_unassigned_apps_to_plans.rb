class AddHideUnassignedAppsToPlans < ActiveRecord::Migration[5.2]
  def up
    add_column :plans, :hide_unassigned_apps, :boolean
    change_column_default :plans, :hide_unassigned_apps, false
  end
  def down
    remove_column :plans, :hide_unassigned_apps
  end
end
