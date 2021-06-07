module Api
  module V1
    module Integrations
      # API controller that provides billing/usage data
      class UsageController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def index
          # TODO: SQL job to join devices, billable instances, accounts, group-by, count, select?

          # rubocop:disable Layout/LineLength
          @start_date = if params[:start_date]
                          Time.zone.parse(params[:start_date])
                        else
                          account.charges.where(status: :completed).last&.end_date || 1.month.ago.beginning_of_day
                        end
          # rubocop:enable Layout/LineLength
          @end_date = if params[:end_date]
                        Time.zone.parse(params[:end_date])
                      else
                        DateTime.current
                      end

          # TODO: UPDATE SWAGGER DOCS AND SEND TO Billy

          # *** Not all of the param searches work yet (most don't)
          # puts root&.id

          build_usage_data(params[:customer_level])

          render json: build_response
        end

        private

        # rubocop:todo Layout/LineLength
        # rubocop:todo Metrics/MethodLength
        def build_usage_data(customer_level)
          root = params[:id].nil? ? account : account.all_descendants.find_by(id: params[:id])
          return if root.nil?

          if customer_level
            @accounts = root.all_descendants.where(type: "Customer").not_trial
            @devices = root.all_descendant_devices
                           .where("last_connected_at > ? and last_connected_at < ?", @start_date, @end_date)
                           .group(:account_path).count
            @firewalls = root.all_descendant_billable_instances.firewall.group(:account_path).count
            @mailboxes = root.all_descendant_billable_instances.office_365_mailbox.group(:account_path).count
            # TODO: can I combine the above two with an extra clause in the group by?
          else
            @devices = {}
            @firewalls = {}
            @mailboxes = {}
            @accounts = root.all_descendants.where(type: "Provider").not_trial
            @accounts = nil if @accounts.blank?
            (@accounts&.all || [root]).each do |provider|
              next if provider.trial?

              @devices[provider.path] = provider.all_descendant_devices
                                                .where("last_connected_at > ? and last_connected_at < ?", @start_date, @end_date).count
              @firewalls[provider.path] = provider.all_descendant_billable_instances.firewall.count
              @mailboxes[provider.path] = provider.all_descendant_billable_instances.office_365_mailbox.count
            end
          end
        end
        # rubocop:enable Layout/LineLength
        # rubocop:enable Metrics/MethodLength

        # rubocop:todo Metrics/MethodLength
        def build_response
          return { "error": "invalid account or no billable accounts" } if @accounts.blank?

          response = []
          total_devices = 0
          total_firewalls = 0
          total_mailboxes = 0
          total_cost = 0
          @accounts.each do |acc|
            next if acc.trial?

            subtotal = ((@devices[acc.path] || 0) + (@firewalls[acc.path] || 0))
            total_cost += subtotal
            total_devices += @devices[acc.path] || 0
            total_firewalls += @firewalls[acc.path] || 0
            total_mailboxes += @mailboxes[acc.path] || 0
            response << {
              name:      acc.name,
              devices:   @devices[acc.path] || 0,
              firewalls: @firewalls[acc.path] || 0,
              mailboxes: @mailboxes[acc.path] || 0,
              subtotal:  subtotal
            }
          end

          {
            total_devices:      total_cost,
            devices:            total_devices,
            firewalls:          total_firewalls,
            mailboxes:          total_mailboxes,
            details:            response,
            billing_start_date: @start_date,
            billing_end_date:   @end_date
          }
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
