module Integrations
  # creates mappings between psa accounts and rocketcyber customers
  class CreateMapping
    CreateMappingError = Class.new(StandardError)

    class << self
      def call(*args)
        new(*args).call
      end
    end

    # carries the parameters required for the mapping
    class Parameters < Dry::Struct
      attribute :customer_ids, Types::Array.of(Types::Coercible::Integer)
      attribute :company_id, Types::Coercible::Integer
    end

    def initialize(account, psa_config, params)
      @account = account
      @psa_config = psa_config
      @params = Parameters.new(params)
      # NOTE: this is currently unused, but in the future it can be used to give
      # partial failure responses. For now, this service is designed to fail hard.
      # In the future, we can implement a more nuanced failure, where some records
      # succeed to be made while others fail
      @errors = []
    end

    attr_reader :account, :psa_config, :params, :errors

    def call
      ActiveRecord::Base.transaction do
        destroy_current_psa_customer_maps!
        maps = []
        customers.each do |customer|
          maps << account.psa_config.psa_customer_maps.new(
            psa_type:       psa_config.psa_type,
            account:        customer,
            psa_company_id: cached_company.external_id,
            cached_company: cached_company
          )
        end
        MassImport.call(PsaCustomerMap, maps, raise_errors: true)
      end

      self
    end

    def errors?
      !errors.empty?
    end

    private

    def destroy_current_psa_customer_maps!
      psa_config.psa_customer_maps.where(account: customers).delete_all
    end

    def cached_company
      # NOTE: this will throw an error if it can't find the cached company
      psa_config.cached_companies.find(params.company_id)
    end

    def customers
      # NOTE: this will throw an error if it can't find the descendant customer
      account.self_and_all_descendant_customers.find(params.customer_ids)
    end
  end
end
