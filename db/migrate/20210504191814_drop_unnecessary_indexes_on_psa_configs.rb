class DropUnnecessaryIndexesOnPsaConfigs < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :psa_configs_cached_companies, column: [:psa_config_id], name: 'index_psa_configs_cached_companies_on_psa_config_id', algorithm: :concurrently
    remove_index :psa_configs_cached_company_types, column: [:psa_config_id], name: 'index_psa_configs_cached_company_types_on_psa_config_id', algorithm: :concurrently
    remove_index :psa_configs_cached_company_types_companies, column: [:psa_config_id], name: 'idx_psa_cached_company_types_companies_on_psa_config', algorithm: :concurrently
  end
end
