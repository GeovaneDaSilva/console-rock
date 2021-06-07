class CreatePsaCustomerMap < ActiveRecord::Migration[5.2]
  def change
    create_table :psa_customer_maps do |t|
      t.integer   :account_id
      t.string    :psa_company_id
      t.integer   :psa_type
      t.integer   :psa_config_id

      t.timestamps
    end
  end
end
