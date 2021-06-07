class AddLogicRuleIdToAppsIncidents < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_incidents, :logic_rule_id, :integer
  end
end
