module Onboarding
  # Control onboarding routing
  class Router
    include Rails.application.routes.url_helpers

    def initialize(account)
      @account = account
    end

    def call
      if @account.provider?
        provider_track
      else
        customer_track
      end
    end

    private

    def provider_track
      if @account.add_customer?
        add_customer_track
      else
        @account.completed!
        root_path
      end
    end

    def customer_track
      if @account.deploy_agent?
        deploy_agent_track
      else
        @account.completed!
        root_path
      end
    end

    def add_customer_track
      if @account.all_descendants.none?
        new_onboarding_customer_path(@account)
      elsif @account.self_and_all_descendant_customers.where.not(id: @account.all_descendants.completed).any?
        self.class.new(
          @account.self_and_all_descendant_customers.where.not(
            id: @account.self_and_all_descendant_customers.completed
          ).first
        ).call
      else
        @account.completed!
        onboarding_complete_path(@account)
      end
    end

    def deploy_agent_track
      if Device.where(customer: @account).none?
        onboarding_agent_path(@account)
      else
        @account.completed!

        self.class.new(
          @account.provider
        ).call
      end
    end
  end
end
