class AddOnboardingToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :onboarding, :integer
    change_column_default :accounts, :onboarding, from: nil, to: 0
  end
end
