module Accounts
  # PSA integration confiuration
  class PsaConfigController < AuthenticatedController
    def create
      authorize account, :can_manage_integrations?
    end

    # rubocop:disable Metrics/BlockNesting
    def update
      authorize account, :can_manage_integrations?

      if params[:customer_types]
        if select_company_types
          if pull_companies
            flash[:notice] = "Selection successful.  Please select which companies to import"
            if params[:create_customers]
              redirect_to account_psa_customer_creation_index_path(account)
              return
            end
          else
            flash[:error] = "Company import failed"
          end
        else
          flash[:error] = "Failed to save selected company types"
        end
      else
        flash[:error] = "There was a problem importing your companies"
      end

      redirect_to account_psa_customer_map_index_path(account)
    end
    # rubocop:enable Metrics/BlockNesting

    def destroy
      authorize account, :can_manage_integrations?
    end

    private

    def select_company_types
      selected_types = psa_config.company_types.map do |n|
        n if params[:customer_types].include?(n[1].to_s)
      end .compact
      psa_config.update(company_types: selected_types)
    end

    def pull_companies
      credentials = Credential.where(
        account: account.self_and_all_ancestors,
        type:    "Credentials::#{psa_config.psa_type}"
      )
      return false unless credentials.size == 1

      Integrations::InitializePsaConfig::PullCompanies.new(psa_config.psa_type,
                                                           credentials.first,
                                                           psa_config)
                                                      .call
    end

    def account
      @account ||= current_account
    end

    def customers
      @customers ||= account.self_and_all_descendant_customers
    end

    def psa_config
      @psa_config ||= account.psa_config
    end
  end
end
