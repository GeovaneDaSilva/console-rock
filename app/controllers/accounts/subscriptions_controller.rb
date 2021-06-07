module Accounts
  # Modify account subscriptions
  class SubscriptionsController < AuthenticatedController
    def create
      authorize account, :edit_notifications?

      subscription = account.subscriptions.new(subscriptions_params)
      subscription.assign_attributes(event_types: [:managed_service_event_summary])

      if subscription.save
        flash[:notice] = "Notification integration added"
      else
        # Because of the tab UI, no error form state
        # Use form validators for required data
        flash[:error] = "Unable to add notification integration"
      end

      redirect_to account_path
    end

    def update
      authorize account, :edit_notifications?
      subscription.assign_attributes(subscriptions_params)

      if account.managed? && !(subscription.is_a?(Subscriptions::Email) && subscription.event_types.blank?)
        if subscription.event_types != [:managed_service_event_summary]
          subscription.assign_attributes(event_types: [:managed_service_event_summary])
        end
      end

      if subscription.save
        flash[:notice] = "Notification integration updated"
      else
        flash[:error] = "Unable to update notification integration"
      end

      redirect_to account_path
    end

    def destroy
      authorize account, :edit_notifications?

      if subscription.destroy
        flash[:notice] = "Notification integration removed"
      else
        flash[:error] = "Unable to remove notification integration"
      end

      redirect_to account_path
    end

    private

    def account
      @account ||= Account.find(params[:account_id])
    end

    def subscription
      @subscription ||= account.subscriptions.find(params[:id])
    end

    def subscriptions_params
      params.require(params[:type].to_sym).permit(
        :type, :customer_identifier, :device_identifier,
        :email_address, :send_blank_email, :phone_number
      )
    end

    def account_path
      if account.provider?
        provider_path(account, anchor: "notifications")
      else
        customer_path(account, anchor: "notifications")
      end
    end

    def email_subscription
      # this is the Subscriptions::Email instance associated with the account of the PSA subscription
      # that was just created/destroyed
      @email_subscription ||= account.subscriptions.email.where.not(event_types: []).first
    end
  end
end
