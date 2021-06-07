module Integrations
  # Pull customer data from PSAs
  class CreateCustomers
    def initialize(customer_hash, psa_config)
      @customer_hash = customer_hash
      @psa_config = psa_config
    end

    attr_reader :psa_config, :customer_hash

    def call
      return if customer_hash.blank? || !psa_config.is_a?(PsaConfig)

      customer_hash.each do |name, id|
        tmp_customer = Customer.new(name: name, path: psa_config.account.path)
        next unless tmp_customer.save

        PsaCustomerMap.new(
          account_id:     tmp_customer.id,
          psa_company_id: id,
          psa_type:       psa_config.psa_type,
          psa_config_id:  psa_config.id,
          cached_company: cached_company(id)
        ).save
      end
    end

    private

    def cached_company(external_id)
      psa_config.cached_companies.find_by(external_id: external_id)
    end
  end
end
