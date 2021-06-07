module Integrations
  # Takes a psa_config and generates/updates company and company type cache data
  # to be used for more efficiently mapping customers to PSA accounts. Supports
  # the advanced mapper.
  class GenerateMappingCaches
    class << self
      def call(*args)
        new(*args).call
      end
    end

    GenerateMappingCachesError = Class.new(StandardError)
    NoCompaniesError = Class.new(GenerateMappingCachesError)

    def initialize(psa_config, reset_caches: false, fetch_new_data: false)
      @psa_config = psa_config
      @reset_caches = reset_caches
      @fetch_new_data = fetch_new_data
      @errors = {}
      @status = :pending
    end

    attr_reader :psa_config, :errors, :status
    # TODO: ensure this credential relationship valid
    delegate :psa_type, :credential, to: :psa_config

    def call
      fetch_new_data! if @fetch_new_data
      ActiveRecord::Base.transaction do
        reset_caches!
        generate_caches!
      end

      @status = :partial if errors.present?

      self
    rescue NoCompaniesError => _e
      errors[:cached_companies] = "No companies to import."
      @status = :failed
      self
    end

    def errors?
      errors.present?
    end

    def success?
      status == :success
    end

    private

    attr_writer :status

    def fetch_new_data!
      psa_config.companies = []
      psa_config.company_types = []
      psa_config.save!
      # QUESTION: do these raise errors if they're unable to fetch data?
      Integrations::InitializePsaConfig::SetupPsaConfig.new(psa_type, credential).call
      psa_config.reload
      # QUESTION: do these raise errors if they're unable to fetch data?
      Integrations::InitializePsaConfig::PullCompanies.new(psa_type, credential, psa_config).call
      psa_config.reload
    end

    def reset_caches!
      psa_config.psa_customer_maps.update_all(psa_configs_cached_company_id: nil)
      psa_config.cached_companies.delete_all
      psa_config.cached_company_types.delete_all
      psa_config.cached_company_types_companies.delete_all
    end

    def generate_caches!
      generate_cached_company_types
      psa_config.reload
      generate_cached_companies
      psa_config.reload
      generate_cached_company_type_companies
      psa_config.reload
    end

    # Error capturing
    # --------------------------------------------------------------------------
    def capture_errors(key, result)
      errors[key.to_sym] = result.errors if result.errors?
    end

    # Model generation methods
    # --------------------------------------------------------------------------
    def generate_cached_company_types
      to_import = []
      psa_config.company_types.each do |(name, external_id)|
        params = { psa_config: psa_config, name: name, external_id: external_id, source: psa_type }
        to_import << PsaConfigs::CachedCompanyType.new(params)
      end
      return true if to_import.blank?

      result = import_cached_company_types(to_import)
      capture_errors(:cached_company_types, result)
      result
    end

    def generate_cached_companies
      to_import = []
      psa_config.companies.each do |(name, external_id, _type_ids)|
        params = { psa_config: psa_config, name: name, external_id: external_id, source: psa_type }
        company = PsaConfigs::CachedCompany.new(params)
        to_import << company
      end
      raise NoCompaniesError if to_import.blank?

      result = import_cached_companies(to_import)
      capture_errors(:cached_companies, result)
      result
    end

    # rubocop:disable Metrics/MethodLength
    def generate_cached_company_type_companies
      to_import = []
      types = psa_config.cached_company_types
                        .map { |type| [type.external_id, type] }
                        .to_h
      companies_type_ids = psa_config.companies
                                     .map { |(_name, external_id, type_ids)| [external_id.to_s, type_ids] }
                                     .to_h

      psa_config.cached_companies.find_each do |cached_company|
        type_ids = companies_type_ids[cached_company.external_id]
        next if type_ids.blank?

        type_ids.each do |type_id|
          cached_company_type = types[type_id.to_s]
          params = { cached_company: cached_company, cached_company_type: cached_company_type,
                     psa_config: psa_config }
          to_import << PsaConfigs::CachedCompanyTypesCompany.new(params)
        end
      end
      return true if to_import.blank?

      result = import_cached_company_type_companies(to_import)
      capture_errors(:cached_company_type_companies, result)
      result
    end
    # rubocop:enable Metrics/MethodLength

    # Import methods
    # --------------------------------------------------------------------------
    def import_cached_company_types(company_types)
      args = {
        on_duplicate_key_update: {
          conflict_target: %i[psa_config_id source external_id],
          columns:         %i[name]
        }
      }
      MassImport.call(PsaConfigs::CachedCompanyType, company_types, args)
    end

    def import_cached_companies(companies)
      args = {
        on_duplicate_key_update: {
          conflict_target: %i[psa_config_id source external_id],
          columns:         %i[name]
        }
      }
      unique_companies = companies.uniq do |company|
        [company.psa_config_id, company.source, company.external_id]
      end
      MassImport.call(PsaConfigs::CachedCompany, unique_companies, args)
    end

    def import_cached_company_type_companies(company_type_companies)
      args = {
        on_duplicate_key_ignore: true
      }
      MassImport.call(PsaConfigs::CachedCompanyTypesCompany, company_type_companies, args)
    end
  end
end
