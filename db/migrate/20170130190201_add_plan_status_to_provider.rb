class AddPlanStatusToProvider < ActiveRecord::Migration[5.0]
  def change
    add_column :providers, :status, :integer, null: false, default: 0
  end
end
