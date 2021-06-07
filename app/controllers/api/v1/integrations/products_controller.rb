module Api
  module V1
    module Integrations
      # API endpoint that returns all products we bill for
      class ProductsController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def index
          render json: product_list.to_json
        end

        private

        # rubocop:todo Metrics/MethodLength
        def product_list
          [
            {
              id:           "device",
              billing_type: "recurring",
              description:  "Number of non-firewall devices with an active RocketAgent this "\
                "billing cycle",
              name:         "device"
            },
            {
              id:           "firewall",
              billing_type: "recurring",
              description:  "Number of network devices (firewall, intelligent AP, intelligent router, etc.) "\
                "monitored by #{I18n.t('application.name')} this billing cycle",
              name:         "firewall"
            },
            {
              id:           "office_365",
              billing_type: "recurring",
              description:  "Number of Office 365 accounts monitored by #{I18n.t('application.name')} this "\
                "billing cycle",
              name:         "office_365"
            }
          ]
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
