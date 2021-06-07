module Accounts
  # Turn a provider into a distributor
  class Distributorify
    def initialize(account)
      @account = account
    end

    def call
      raise "Account must be a provider" unless @account.provider?
      raise "Account already has sub-providers" if @account.children.providers.any?

      subscribe_root_provider!
      create_sub_providers!
      move_customers!
    end

    private

    def subscribe_root_provider!
      @account.update(plan: managed_plan)
    end

    def create_sub_providers!
      pro_provider
      managed_provider
    end

    def move_customers!
      new_customer_account = @account.plan == pro_plan ? pro_provider : managed_provider

      @account.customers.each { |account| account.update(path: new_customer_account.path) }
    end

    def pro_provider
      @pro_provider ||= Provider.create(
        name: "#{@account.name} (Pro)", path: @account.path, onboarding: :completed,
        plan: pro_plan, paid_thru: @account.paid_thru
      )
    end

    def managed_provider
      @managed_provider ||= Provider.create(
        name: "#{@account.name} (Managed)", path: @account.path, onboarding: :completed,
        plan: managed_plan, paid_thru: @account.paid_thru
      )
    end

    def pro_plan
      Plan.find_by(name: "Professional")
    end

    def managed_plan
      Plan.find_by(name: "Managed Endpoint Detection & Response")
    end
  end
end
