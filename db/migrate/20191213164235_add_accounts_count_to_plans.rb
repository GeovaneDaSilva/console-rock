class AddAccountsCountToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :accounts_count, :integer
    change_column_default :plans, :accounts_count, from: nil, to: 0

    reversible do |dir|
      dir.up do
        Plan.update_all("accounts_count = providers_count")
      end
    end
  end
end
