module Accounts
  # Enable or disable Apps for account
  class AppsController < AuthenticatedController
    helper_method :apps, :discreet_apps

    def index
      authorize account, :can_manage_apps?
    end

    def update
      authorize account, :can_manage_apps?

      disabled_at = params["enabled"].present? ? nil : DateTime.current
      enabled_at  = disabled_at.blank? ? DateTime.current : app.enabled_at

      app.update(disabled_at: disabled_at, enabled_at: enabled_at)

      broadcast_app_check!

      respond_to do |format|
        format.html { redirect_to account_apps_path(account) }
        format.js { head :ok }
      end
    end

    private

    def account
      @account ||= policy_scope(Account).find(params[:account_id])
    end

    def apps
      @apps ||= filter_managed_apps.enabled.ga.order(author: :asc, title: :asc)
                                   .includes(:display_image, :display_image_icon).load
    end

    def discreet_apps
      filter_managed_apps.discreet.includes(:display_image, :display_image_icon)
    end

    def app
      @app ||= account.account_apps.find(params[:id])
    end

    def broadcast_app_check!
      account.self_and_all_descendant_customers.each do |customer|
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Customer", customer,
          { type: "apps", payload: {} }.to_json
        )
      end
    end

    def filter_managed_apps
      current_account&.managed? ? App.all : App.unmanaged_only
    rescue NoMethodError
      App.all
    end
  end
end
