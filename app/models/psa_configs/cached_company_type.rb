module PsaConfigs
  # holds the most recent API response for company types to enable advanced searching
  # while setting up customer mapping
  class CachedCompanyType < ApplicationRecord
    belongs_to :psa_config, optional: false
    has_many :cached_company_types_companies, dependent:   :delete_all,
                                              class_name:  "::PsaConfigs::CachedCompanyTypesCompany",
                                              foreign_key: "psa_configs_cached_company_type_id",
                                              inverse_of:  :cached_company_type
    has_many :cached_companies, through: :cached_company_types_companies,
                                source:  :cached_company
  end
end
