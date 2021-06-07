class AddPsaConfigsCachedCompanyTypeToPsaConfigsCachedCompany < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :psa_configs_cached_company_types_companies do |t|
      t.belongs_to :psa_config, null: false, index: { algorithm: :concurrently, name: 'idx_psa_cached_company_types_companies_on_psa_config' }
      t.belongs_to :psa_configs_cached_company, null: false, index: { algorithm: :concurrently, name: 'idx_psa_cached_company_types_companies_on_company' }
      t.belongs_to :psa_configs_cached_company_type, index: { algorithm: :concurrently, name: 'idx_psa_cached_company_types_companies_on_type' }

      t.index [:psa_config_id, :psa_configs_cached_company_type_id, :psa_configs_cached_company_id], unique: true, name: 'idx_cached_company_types_companies_unique_index_on_mapping', algorithm: :concurrently

      t.timestamps
    end
  end
end
