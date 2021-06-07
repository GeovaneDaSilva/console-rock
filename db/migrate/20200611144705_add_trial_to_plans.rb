class AddTrialToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :trial, :boolean
  end
end
