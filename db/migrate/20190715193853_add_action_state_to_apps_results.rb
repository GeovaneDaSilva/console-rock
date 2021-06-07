class AddActionStateToAppsResults < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_results, :action_state, :integer
    add_column :apps_results, :action_result, :jsonb

    change_column_default :apps_results, :action_result, from: nil, to: {}
  end
end
