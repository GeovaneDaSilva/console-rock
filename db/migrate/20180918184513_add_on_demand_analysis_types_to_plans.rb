class AddOnDemandAnalysisTypesToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :on_demand_analysis_types, :integer
    change_column_default :plans, :on_demand_analysis_types, from: nil, to: 0
  end
end
