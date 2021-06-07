module Accounts
  module PsaCustomerMaps
    # Takes a psa_config and generates search scopes based on the passed company_type_ids
    # and a company query string
    class PsaCompanySearchQuery
      def initialize(psa_config, companies_params, company_types_params)
        @psa_config = psa_config
        @companies_params = companies_params
        @company_types_params = company_types_params
      end

      attr_reader :psa_config, :companies_params, :company_types_params

      def company_types
        psa_config.cached_company_types.tap! do |relation|
          return relation.none if company_types_params.ignore

          relation = relation.order(:name)
          relation
        end
      end

      def companies
        psa_config.cached_companies.includes(:psa_customer_maps).tap! do |relation|
          return relation.none if companies_params.ignore

          if companies_params.company_types.present?
            relation = relation.joins(:cached_company_types)
                               .merge(PsaConfigs::CachedCompanyType.where(id: companies_params.company_types))
          end
          if companies_params.no_connection
            relation = relation.left_outer_joins(:psa_customer_maps)
                               .where("psa_customer_maps.id IS NULL")
          end

          relation = relation.order(:name)
          relation = relation.limit(companies_params.limit)
          relation = relation.offset(companies_params.offset)
          relation = relation.search_name(companies_params.q) if companies_params.q.present?
          relation
        end
      end
    end
  end
end
