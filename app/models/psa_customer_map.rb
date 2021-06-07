# nodoc
class PsaCustomerMap < ApplicationRecord
  belongs_to :account
  belongs_to :psa_config
  belongs_to :cached_company, class_name:  "PsaConfigs::CachedCompany",
                              foreign_key: "psa_configs_cached_company_id",
                              inverse_of:  :psa_customer_maps

  enum psa_type: {
    Connectwise: 1,
    Datto:       2,
    Syncro:      3,
    Kaseya:      4
  }
end
