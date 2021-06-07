module Accounts
  # :nodoc
  class ChargesController < AuthenticatedController
    include Chargeable

    layout false
    helper_method :account, :charge, :plan, :filename

    def show
      authorize account, :can_modify_plan?
    end

    private

    def account
      @account ||= Account.find(params[:account_id])
    end

    def charge
      @charge ||= account.charges.find(params[:id])
    end

    def plan
      @plan ||= charge.plan
    end
  end
end
