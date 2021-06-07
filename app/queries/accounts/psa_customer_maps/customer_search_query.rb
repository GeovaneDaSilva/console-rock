module Accounts
  module PsaCustomerMaps
    # Takes a psa_config and generates search scopes based on the passed company_type_ids
    # and a company query string
    class CustomerSearchQuery
      def initialize(account, params)
        @account = account
        @params = params
      end

      attr_reader :account, :params

      def customers
        return Account.none if params.ignore

        account.self_and_all_descendant_customers.includes(:psa_customer_map).tap! do |relation|
          return relation.none if params.ignore

          if params.no_connection
            # NOTE: assumes that there is no connection if there is no PsaCustomerMap joined to the account
            # This may break if there's a case where instead of deleting the PsaCustomerMap, we simply nullify
            # the column carrying the psa_company_id or psa_configs_cached_company_id
            relation = relation.left_outer_joins(:psa_customer_map)
                               .where("psa_customer_maps.id IS NULL")
          end

          relation = relation.order(:name)
          relation = relation.limit(params.limit)
          relation = relation.offset(params.offset)
          relation = relation.search_name(params.q) if params.q.present?

          relation
        end
      end
    end
  end
end
