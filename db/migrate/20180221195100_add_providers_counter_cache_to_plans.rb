class AddProvidersCounterCacheToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :providers_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Plan.reset_column_information

        Plan.find_each do |plan|
          Plan.reset_counters(plan.id, :providers)
        end
      end
    end
  end
end
