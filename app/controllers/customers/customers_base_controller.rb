module Customers
  # Base controller for customer based resources
  class CustomersBaseController < AuthenticatedController
    before_action :find_customer

    private

    def find_customer
      @customer ||= Customer.find(params[:customer_id])
    end
  end
end
