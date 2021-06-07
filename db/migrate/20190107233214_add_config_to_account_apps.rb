class AddConfigToAccountApps < ActiveRecord::Migration[5.2]
  def change
    add_column :account_apps, :config, :jsonb
    change_column_default :account_apps, :config, from: nil, to: {}

    reversible do |dir|
      dir.up do
        AccountApp.update_all(config: {})
      end
    end
  end
end
