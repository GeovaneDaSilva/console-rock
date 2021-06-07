class CreatePlanApps < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_apps do |t|
      t.references :plan, foreign_key: true
      t.references :app, foreign_key: true

      t.timestamps
    end
  end
end
