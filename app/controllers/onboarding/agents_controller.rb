module Onboarding
  # :nodoc
  class AgentsController < BaseController
    before_action :agents_deployed?

    helper_method :account

    def show
      authorize(account, :show?)

      @agent_url = api_customer_support_url(account.license_key, I18n.t("agent.installer_name"))

      response.set_header("X-Redirect-Location", root_path) if agents_deployed?
    end

    private

    def agents_deployed?
      account.all_descendant_devices.any?
    end
  end
end
