module Api
  module V1
    module Integrations
      # API controller that provides billing/usage data
      class BillingController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def index
          @start_date = if params[:start_date]
                          Time.zone.parse(params[:start_date])
                        else
                          account.charges
                                 .where(status: :completed).last&.end_date || 1.month.ago.beginning_of_day
                        end
          @end_date = if params[:end_date]
                        Time.zone.parse(params[:end_date])
                      else
                        DateTime.current
                      end

          render json: { error: "invalid account" }, status: :not_found if accounts_to_bill.nil?

          build_usage_data

          render json: build_response
        end

        private

        def base_account
          @base_account ||= account.all_descendants.find_by(id: params[:account_id]) || account
        end

        def accounts_to_bill
          @accounts_to_bill ||= base_account&.all_descendant_customers&.order(:name)
        end

        # rubocop:todo Layout/LineLength
        def build_usage_data
          @devices = {}
          @firewalls = {}
          # @mailboxes = {}

          accounts_to_bill.each do |customer|
            next if customer.billing_account.trial?

            @devices[customer.path] = customer.devices
                                              .where("last_connected_at > ? and last_connected_at < ?", @start_date, @end_date).count
            @firewalls[customer.path] = customer.all_descendant_billable_instances.firewall.count
            # @mailboxes[customer.path] = customer.all_descendant_billable_instances.office_365_mailbox.count
          end
        end
        # rubocop:enable Layout/LineLength

        # rubocop:todo Metrics/MethodLength
        def build_response
          response = []
          total_devices = 0
          total_firewalls = 0
          # total_mailboxes = 0
          total_cost = 0
          accounts_to_bill.each do |acc|
            next if acc.billing_account.trial?

            subtotal = ((@devices[acc.path] || 0) + (@firewalls[acc.path] || 0))
            total_cost += subtotal
            total_devices += @devices[acc.path] || 0
            total_firewalls += @firewalls[acc.path] || 0
            # total_mailboxes += @mailboxes[acc.path] || 0
            response << {
              name:      acc.name,
              devices:   @devices[acc.path] || 0,
              firewalls: @firewalls[acc.path] || 0,
              # mailboxes: @mailboxes[acc.path] || 0,
              subtotal:  subtotal
            }
          end

          plan = base_account&.billing_account&.plan
          included_devices = plan&.included_devices || 0
          included_firewalls = plan&.included_firewalls || 0
          billable_devices = [0, (total_devices - included_devices)].max
          billable_firewalls = [0, (total_firewalls - included_firewalls)].max

          {
            total:              billable_devices + billable_firewalls,
            devices:            billable_devices,
            firewalls:          billable_firewalls,
            # mailboxes:          total_mailboxes,
            details:            response,
            billing_start_date: @start_date,
            billing_end_date:   @end_date,
            last_bill:          base_account.charges.order(:end_date).first&.end_date
          }
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
