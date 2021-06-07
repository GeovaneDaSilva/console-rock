module Accounts
  # Display integrations page
  class ApiIntegrationsController < AuthenticatedController
    def create
      authorize current_account, :editor?

      params[:map].each do |key, value|
        map = maps.where(account_id: key).first_or_initialize

        if value[:integration_id].blank?
          map.destroy
        else
          map.update(target_id: value[:integration_id])
        end
      end

      redirect_to account_integrations_path(current_account, { anchor: "email_security" })
    end

    private

    def maps
      # @maps ||= RocketcyberIntegrationMap.where(account_id: params[:maps].keys, type: params[:type])
      @maps ||= RocketcyberIntegrationMap.where(account: sub_accounts, map_type: params[:type])
    end

    def sub_accounts
      @sub_accounts ||= Account.where(id: params[:map].keys)
    end
  end
end

# your input find/replace [=[ and ]=] with ""
