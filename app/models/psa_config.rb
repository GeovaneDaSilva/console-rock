# nodoc
class PsaConfig < ApplicationRecord
  include AttrJsonable
  # include Encryptable

  BASIC_PSA_MAPPER_KEY = "basic_mapper".freeze
  ADVANCED_PSA_MAPPER_KEY = "advanced_mapper".freeze

  after_initialize :set_default_values
  after_save :update_caches!

  belongs_to :account
  belongs_to :credential

  has_many :psa_customer_maps, dependent: :destroy
  has_many :cached_companies, dependent:  :delete_all,
                              class_name: "::PsaConfigs::CachedCompany",
                              inverse_of: :psa_config
  has_many :cached_company_types, dependent:  :delete_all,
                                  class_name: "::PsaConfigs::CachedCompanyType",
                                  inverse_of: :psa_config
  has_many :cached_company_types_companies, dependent:  :delete_all,
                                            class_name: "::PsaConfigs::CachedCompanyTypesCompany",
                                            inverse_of: :psa_config

  attr_json_accessor :configs, :new_ticket_code, :in_progress_ticket_code, :closed_ticket_code, :psa_type,
                     :status_codes, :board, :board_options, :companies, :company_types, :datto_priority,
                     :priority_codes, :priority, :ticket_types, :ticket_type, :ticket_source,
                     :kaseya_location_map, :mapping_feature

  private

  def update_caches!
    return unless generate_mapping_caches?

    result = Integrations::SetupAdvancedMapper.call(reload)
    errors.add(:base, "Generating mapping caches failed. Please contact support.") if result.errors?
  end

  # NOTE: for after_save only
  def generate_mapping_caches?
    saved_change_to_configs? && companies.size.positive?
  end

  def set_default_values
    self.companies ||= []
    self.company_types ||= []
    self.mapping_feature ||= BASIC_PSA_MAPPER_KEY
  end
end
