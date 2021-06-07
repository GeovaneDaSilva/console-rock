module Api
  module V1
    module Devices
      # Base for all Account based resources
      class DevicesBaseController < Api::V1::BaseController
        helper_method :device

        before_action :device
        around_action :device_time

        private

        def device
          @device ||= Device.find(params[:device_id].downcase)
        rescue ActiveRecord::RecordNotFound
          @device = Device.find_by!(uuid: params[:device_id].downcase)
        end

        def customer
          @customer ||= @device.customer
        end

        def root
          customer.root
        end

        def root_and_all_descendants
          root.self_and_all_descendants
        end

        def device_time(&block)
          Time.use_zone(@device.timezone, &block)
        end

        def payment_requried?
          raise PaymentRequiredError if customer.billing_account.actionable_past_due?
        end
      end
    end
  end
end
