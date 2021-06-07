module Accounts
  # Allow for mapping PSA company ID to RocketCyber Customers
  class PsaCustomerMapController < AuthenticatedController
    extend Lettable

    before_action { authorize(account, :can_manage_integrations?) }
    before_action :verify_psa_config_presence

    let(:form) do
      Accounts::PsaCustomerMaps::SearchQueryForm.new(
        account,
        psa_config,
        customers_params.to_h.symbolize_keys,
        companies_params.to_h.symbolize_keys,
        company_types_params.to_h.symbolize_keys
      )
    end
    let(:account) { Account.find(params[:account_id]) }
    let(:psa_config) { PsaConfig.find_by(account: account) }
    let(:is_advanced_psa_customer_mapping_enabled) do
      Flipper.enabled?("integrations/psa-mapping/advanced", account)
    end
    let(:customers) do
      account.self_and_all_descendant_customers.includes(:psa_customer_map).order(:name)
    end

    def index
      if params[:credential_type] == "Credentials::Syncro"
        redirect_to account_psa_customer_creation_index_path(account)
      end
    end

    def create
      psa_customer_map_params.each do |(account_id, psa_company_id)|
        map = PsaCustomerMap.where(
          account_id:    account_id.to_i,
          psa_type:      psa_config.psa_type,
          psa_config_id: psa_config.id
        ).first_or_initialize
        map.update(psa_company_id: psa_company_id)
      end

      flash[:notice] = "PSA company mapping saved"

      redirect_to account_integrations_path(account)
    end

    def create_advanced
      @result = Integrations::CreateMapping.call(
        account,
        psa_config,
        create_advanced_params.to_h.symbolize_keys
      )
    end

    def destroy_advanced
      @result = Integrations::DestroyMapping.call(
        account,
        psa_config,
        destroy_advanced_params.to_h.symbolize_keys
      )
    end

    def search; end

    private

    def verify_psa_config_presence
      if psa_config.blank?
        flash[:error] = "Please create a PSA config before mapping your customers."
        redirect_to account_integrations_path
      end
    end

    def psa_customer_map_params
      params[:customer_types].delete_if { |_k, v| v.blank? }
    end

    def customers_params
      params.fetch(:customers, {}).permit(:q, :no_connection, :limit, :offset,
                                          :ignore)
    end

    def companies_params
      params.fetch(:companies, {}).permit(:q, :no_connection, :limit, :offset,
                                          :ignore, company_types: [])
    end

    def company_types_params
      params.fetch(:company_types, {}).permit(:ignore)
    end

    def create_advanced_params
      params.require(:create).permit(:company_id, customer_ids: [])
    end

    def destroy_advanced_params
      params.require(:destroy).permit(customer_ids: [])
    end
  end
end
