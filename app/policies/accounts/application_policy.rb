module Accounts
  # Plan based policies
  class ApplicationPolicy
    attr_reader :account, :record
    delegate :root, to: :account
    delegate :billing_account, to: :account
    delegate :plan, to: :billing_account

    def initialize(account, record)
      @account = account
      @record  = record
    end
  end
end
