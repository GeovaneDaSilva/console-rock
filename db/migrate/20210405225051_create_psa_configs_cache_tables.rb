class CreatePsaConfigsCacheTables < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :psa_configs_cached_companies do |t|
      t.belongs_to :psa_config, foreign_key: true
      t.string :name, null: false
      t.string :source, null: false
      t.string :external_id, null: false
      t.jsonb :metadata

      t.index [:psa_config_id, :source, :external_id], unique: true, name: "idx_cached_companies_on_source_external_id", algorithm: :concurrently

      t.timestamps
    end

    create_table :psa_configs_cached_company_types do |t|
      t.belongs_to :psa_config, foreign_key: true
      t.string :name, null: false
      t.string :source, null: false
      t.string :external_id, null: false
      t.jsonb :metadata

      t.index [:psa_config_id, :source, :external_id], unique: true, name: "idx_cached_company_types_on_source_external_id", algorithm: :concurrently

      t.timestamps
    end

  end
end
