class AddTriageToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :triage, :boolean
  end
end
