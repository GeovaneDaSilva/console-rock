class AddConfigurationTypeToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :configuration_type, :integer
  end
end
