module Integrations
  # converts a pre-existing psa_config and its customer maps to the new advanced_mapper format
  class SetupAdvancedMapper
    class << self
      def call(*args)
        new(*args).call
      end
    end

    SetupAdvancedMapperError = Class.new(StandardError)
    MissingParameterError = Class.new(SetupAdvancedMapperError)

    def initialize(psa_config, fetch_new_data: false)
      @psa_config = psa_config
      @fetch_new_data = fetch_new_data
      @errors = {}
    end

    attr_reader :psa_config, :errors

    def call
      raise MissingParameterError, "No psa_config was passed in" if psa_config.blank?

      ActiveRecord::Base.transaction do
        generate_mapping_caches!
        migrate_existing_customer_mappings!
      end

      self
    end

    def errors?
      errors.present?
    end

    private

    def generate_mapping_caches!
      generate_mapping_caches_result = Integrations::GenerateMappingCaches.call(
        psa_config,
        fetch_new_data: @fetch_new_data
      )
      capture_errors(:generate_mapping_caches, generate_mapping_caches_result)
    end

    def migrate_existing_customer_mappings!
      customer_maps = psa_config.psa_customer_maps.load
      return if customer_maps.blank?

      mappings_missing_cached_companies = []

      customer_maps.each do |customer_map|
        external_id = Integer(customer_map.psa_company_id)
        cached_company = psa_config.cached_companies.find_by!(external_id: external_id)
        customer_map.cached_company = cached_company
        customer_map.save!
      rescue ActiveRecord::RecordNotFound => _e
        mappings_missing_cached_companies << [customer_map, Integer(customer_map.psa_company_id)]
      end
      # rubocop:disable Style/GuardClause
      if mappings_missing_cached_companies.present?
        @errors[:migrate_existing_customer_mappings] = mappings_missing_cached_companies
      end
      # rubocop:enable Style/GuardClause
    end

    def capture_errors(key, result)
      @errors[key] = result.errors if result.errors?
    end
  end
end
