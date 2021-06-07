class CreateRocketcyberIntegrationMap < ActiveRecord::Migration[5.2]
  def change
    create_table :rocketcyber_integration_maps do |t|
      t.integer   :account_id
      t.ltree     :account_path
      t.string    :target_id
      t.integer   :app_id
      t.integer   :mapping_config_id
      t.string    :map_type
    end
  end
end
