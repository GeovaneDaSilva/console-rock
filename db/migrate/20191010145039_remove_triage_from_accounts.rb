class RemoveTriageFromAccounts < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :accounts, :triage, :boolean }
  end
end
