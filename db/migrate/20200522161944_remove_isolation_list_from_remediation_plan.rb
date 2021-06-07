class RemoveIsolationListFromRemediationPlan < ActiveRecord::Migration[5.2]
  def up
    safety_assured { remove_column :remediation_plans, :isolation_list, :text }
  end

  def down
    add_column :remediation_plans, :isolation_list, :test
  end
end
