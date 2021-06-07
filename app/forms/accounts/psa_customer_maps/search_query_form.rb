module Accounts
  module PsaCustomerMaps
    # Form object to hold attributes incoming from PSA Mapper search form
    class SearchQueryForm
      include ActiveModel::Model

      # holds the required parameters for running a query with this form
      class Query < Dry::Struct
        Q_DEFAULT = "".freeze

        attribute :q, Types::Coercible::String.default(Q_DEFAULT)
        attribute :no_connection, Types::Params::Bool.default(false)
        attribute :limit, Types::Params::Integer.default(10)
        attribute :offset, Types::Params::Integer.default(0)
        attribute :ignore, Types::Params::Bool.default(false)
      end

      # holds the required parameters for the companies query
      class CompaniesQuery < Query
        COMPANY_TYPES_DEFAULT = [].freeze

        attribute :company_types, Types::Array.of(Types::Coercible::Integer.optional)
                                              .default(COMPANY_TYPES_DEFAULT)
      end

      # holds the required parameters for the customers query
      class CustomersQuery < Query; end
      # holds the required parameters for the company_types query
      class CompanyTypesQuery < Dry::Struct
        attribute :ignore, Types::Params::Bool.default(false)
      end

      def initialize(account, psa_config, customers_params, companies_params, company_types_params)
        @account = account
        @psa_config = psa_config
        @customers_params = CustomersQuery.new(customers_params)
        @companies_params = CompaniesQuery.new(companies_params)
        @company_types_params = CompanyTypesQuery.new(company_types_params)
      end

      attr_reader :account, :psa_config, :customers_params, :companies_params, :company_types_params

      delegate :customers, :companies, to: :query

      def query
        Accounts::PsaCustomerMaps::SearchQuery.new(
          account,
          psa_config,
          customers_params,
          companies_params,
          company_types_params
        )
      end
    end
  end
end
