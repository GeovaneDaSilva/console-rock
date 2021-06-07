class AddPsaCustomerMapReferenceToPsaConfigsCachedCompanies < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :psa_customer_maps, :psa_configs_cached_company, index: { algorithm: :concurrently }
  end
end
