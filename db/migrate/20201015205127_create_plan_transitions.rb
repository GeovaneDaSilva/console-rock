class CreatePlanTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_transitions do |t|
      t.integer :from_plan
      t.integer :to_plan
    end

    add_index :plan_transitions, :from_plan
  end
end
