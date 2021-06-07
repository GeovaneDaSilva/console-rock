module Api
  module V1
    module Customers
      # Base for all Account based resources
      class CustomersBaseController < Api::V1::BaseController
        before_action :find_customer, :payment_requried?

        private

        # These strip out null bytes because we were having a problem with them getting sent up
        def db_license_key
          params[:customer_id].split("-").first.gsub("\u0000", "")
        end

        def license_key_id
          params[:customer_id].split("-").last.gsub("\u0000", "")
        end

        def deleted_customer
          @deleted_customer ||= DeletedCustomer.find_by!(license_key: db_license_key)
        end

        def find_customer
          @customer ||= Customer.find_by(license_key: db_license_key) || deleted_customer
          head :forbidden if @customer.nil?
        rescue ActiveRecord::RecordNotFound
          # If the customer no longer exists, agents shouldn't be trying to check for updates
          # Agent should uninstall with 403 response
          Rails.logger.fatal(
            "Connection attempt with invalid license key #{db_license_key}, ID: #{license_key_id || '?'}"
          )

          head :forbidden
        end

        def payment_requried?
          return if skip_payment_required? || @customer.is_a?(DeletedCustomer)

          raise PaymentRequiredError if @customer.billing_account.actionable_past_due?
        end

        def skip_payment_required?
          false
        end
      end
    end
  end
end
