module Accounts
  # Send the given app message to all devices for the account
  class AppActionsController < AuthenticatedController
    include AppActionable

    def create
      authorize account, :app_action?

      broadcast_app_check!
      flash[:notice] = "Requested all #{account.name} devices #{action[:description].downcase}"

      respond_to do |format|
        format.html do
          redirect_to root_path
        end

        format.js
      end
    end

    private

    def account
      @account ||= policy_scope(Account).find(params[:account_id])
    end

    def broadcast_app_check!
      account.self_and_all_descendant_customers.each do |customer|
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Customer", customer,
          broadcast_message.to_json
        )
      end
    end
  end
end
