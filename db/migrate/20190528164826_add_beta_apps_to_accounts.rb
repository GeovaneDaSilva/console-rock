class AddBetaAppsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :beta_apps, :boolean
    change_column_default :accounts, :beta_apps, from: nil, to: false

    reversible do |dir|
      dir.up do
        Account.reset_column_information

        Account.update_all(beta_apps: false)
      end
    end
  end
end
