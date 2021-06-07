module PsaConfigs
  # Join model for company_types to company
  class CachedCompanyTypesCompany < ApplicationRecord
    belongs_to :psa_config
    belongs_to :cached_company_type, class_name:  "PsaConfigs::CachedCompanyType",
                                     foreign_key: "psa_configs_cached_company_type_id",
                                     inverse_of:  :cached_company_types_companies
    belongs_to :cached_company, class_name:  "PsaConfigs::CachedCompany",
                                foreign_key: "psa_configs_cached_company_id",
                                inverse_of:  :cached_company_types_companies
  end
end
