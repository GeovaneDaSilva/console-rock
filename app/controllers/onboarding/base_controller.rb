module Onboarding
  # :nodoc
  class BaseController < AuthenticatedController
    private

    def account
      @account ||= Account.find(params[:onboarding_id])
    end

    def skip_onboarding_redirect?
      true
    end
  end
end
