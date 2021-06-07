module Accounts
  module PsaCustomerMaps
    # Takes a psa_config and generates search scopes based on the passed company_type_ids
    # and a company query string
    class SearchQuery
      def initialize(account, psa_config, customers_params, companies_params, company_types_params)
        @account = account
        @psa_config = psa_config
        @customers_params = customers_params
        @companies_params = companies_params
        @company_types_params = company_types_params
      end

      attr_reader :account, :psa_config, :customers_params, :companies_params,
                  :company_types_params

      delegate :companies, :company_types, to: :psa_company_search_query
      delegate :customers, to: :customer_search_query

      private

      def customer_search_query
        @customer_search_query ||= Accounts::PsaCustomerMaps::CustomerSearchQuery.new(
          account,
          customers_params
        )
      end

      def psa_company_search_query
        @psa_company_search_query ||= Accounts::PsaCustomerMaps::PsaCompanySearchQuery.new(
          psa_config,
          companies_params,
          company_types_params
        )
      end
    end
  end
end
