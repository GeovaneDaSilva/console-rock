class AddConfigurationScopeToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :configuration_scopes, :text, array: true

    change_column_default :apps, :configuration_scopes, from: nil, to: []

    reversible do |dir|
      dir.up do
        App.reset_column_information
        App.update_all(configuration_scopes: %w[provider customer device])

        types = [
          App.configuration_types["secure_now"], App.configuration_types["powershell_runner"],
          App.configuration_types["office365"], App.configuration_types["office365_signin"]
        ]
        App.where(configuration_type: types).update_all(configuration_scopes: %w[customer])
      end
    end
  end
end
