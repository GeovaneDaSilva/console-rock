module Api
  module V1
    # Customer
    class CustomersController < Api::V1::BaseController
      def show
        @customer = find_customer

        if @customer.is_a?(Customer)
          render :show, status: :ok
        elsif @customer.is_a?(DeletedCustomer)
          render :deleted_customer, status: :ok
        end
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      private

      def find_customer
        Customer.find_by(license_key: db_license_key) || deleted_customer
      end

      def deleted_customer
        @deleted_customer ||= DeletedCustomer.find_by!(license_key: db_license_key)
      end

      def db_license_key
        params[:id].split("-").first.gsub("\u0000", "")
      end
    end
  end
end
