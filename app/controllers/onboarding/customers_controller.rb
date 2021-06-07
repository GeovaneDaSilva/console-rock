module Onboarding
  # :nodoc
  class CustomersController < BaseController
    def new
      authorize account, :create_customers?
      @customer = Customer.new
    end

    def create
      authorize account, :create_customers?

      @customer = Customer.new(customer_params)
      if @customer.save
        AdministrationMailer.new_account(@customer).deliver_later
        redirect_to root_path
      else
        render :new
      end
    end

    private

    def customer_params
      params.require(:customer).permit(
        :name
      ).merge(path: account.path)
    end
  end
end
