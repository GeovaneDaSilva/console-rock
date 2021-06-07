module Integrations
  # creates mappings between psa accounts and rocketcyber customers
  class DestroyMapping
    class << self
      def call(*args)
        new(*args).call
      end
    end

    # carries the parameters required for the mapping
    class Parameters < Dry::Struct
      attribute :customer_ids, Types::Array.of(Types::Coercible::Integer)
    end

    def initialize(account, psa_config, params)
      @account = account
      @psa_config = psa_config
      @params = Parameters.new(params)
      @errors = []
    end

    attr_reader :account, :psa_config, :params, :errors

    def call
      ActiveRecord::Base.transaction do
        destroy_current_psa_customer_maps!
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

    def customers
      account.self_and_all_descendant_customers.find(params.customer_ids)
    end
  end
end
