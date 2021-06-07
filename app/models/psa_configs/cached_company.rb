module PsaConfigs
  # holds the most recent API response for companies to enable advanced searching
  # while setting up customer mapping
  class CachedCompany < ApplicationRecord
    include PgSearch::Model
    include AttrJsonable

    pg_search_scope :search_name, against: :name, using: {
      tsearch: { prefix: true, negation: true, dictionary: "english" }
    }

    pg_search_scope :search_any_name, against: :name, using: {
      tsearch: { prefix: true, negation: true, dictionary: "english", any_word: true }
    }

    belongs_to :psa_config, optional: false
    has_many :psa_customer_maps, dependent:   :nullify,
                                 foreign_key: "psa_configs_cached_company_id",
                                 inverse_of:  :cached_company

    has_many :cached_company_types_companies, dependent:   :delete_all,
                                              class_name:  "::PsaConfigs::CachedCompanyTypesCompany",
                                              foreign_key: "psa_configs_cached_company_id",
                                              inverse_of:  :cached_company
    has_many :cached_company_types, through: :cached_company_types_companies,
                                    source:  :cached_company_type

    attr_json_reader :metadata, :types
  end
end
