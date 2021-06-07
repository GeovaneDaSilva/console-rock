module Braintree
  CreationError = Class.new(StandardError)
  # Creates or updates a Braintree customer object
  class CustomerBuilder
    def initialize(provider)
      @provider = provider
    end

    def call
      return requeue! unless owner

      response = existing_customer? ? update_customer! : create_customer!

      if response.success?
        @provider.update(braintree_customer_id: response.customer.id)
      else
        @provider.update(braintree_customer_id: nil)

        raise BraintreeCreationError, "Unable to create Braintree customer for Provider: #{@provider.id}"
      end
    end

    private

    def existing_customer?
      @customer ||= Braintree::Customer.find(@provider.id)
    rescue Braintree::NotFoundError
      nil
    end

    def update_customer!
      Braintree::Customer.update(
        @provider.id,
        first_name: owner.first_name,
        last_name:  owner.last_name,
        email:      owner.email,
        company:    @provider.name
      )
    end

    def create_customer!
      Braintree::Customer.create(
        id:         @provider.id,
        first_name: owner.first_name,
        last_name:  owner.last_name,
        email:      owner.email,
        company:    @provider.name
      )
    end

    def billing_address
      {
        first_name:       first_name,
        last_name:        last_name,
        street_address:   @provider.street_1,
        extended_address: @provider.street_2,
        locality:         @provider.city,
        region:           @provider.state,
        postal_code:      @provider.zip_code
      }
    end

    def owner
      @owner ||= UserRole.joins(:account)
                         .where(account: @provider.self_and_ancestors)
                         .order("accounts.path DESC")
                         .includes(:user)
                         .first
                         &.user
    end

    def requeue!
      ServiceRunnerJob.set(wait: 10.minutes)
                      .perform_later(self.class.name, @provider)
    end
  end
end
