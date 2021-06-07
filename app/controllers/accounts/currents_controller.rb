module Accounts
  # Set the current_account
  class CurrentsController < AuthenticatedController
    before_action :find_account, only: [:create]

    def create
      authorize @account, :show?

      session[:account_id] = @account.id

      redirect_to root_path
    end

    private

    def find_account
      @account = Account.find(params[:account_id])
    end

    def skip_onboarding_redirect?
      true
    end

    def skip_credit_card_required?
      true
    end
  end
end
