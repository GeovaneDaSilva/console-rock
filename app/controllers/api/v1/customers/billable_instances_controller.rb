module Api
  module V1
    module Customers
      # Account billable instances
      # Allow billable instances and their details to be register via API
      class BillableInstancesController < Api::V1::Customers::CustomersBaseController
        def update
          return :payment_required if @customer.is_a?(DeletedCustomer)

          billable_instance.with_lock do
            billable_instance.assign_attributes(details: permitted_params)
            billable_instance.updated_at = DateTime.current if !billable_instance.changed?

            skip = false
            if billable_instance.new_record?
              log_lookup!
            elsif permitted_params["type"] == "unknown"
              skip = true
            end

            head :created if !skip && billable_instance.save!
          end
        end

        private

        def billable_instance
          return @billable_instance unless @billable_instance.nil?

          @billable_instance ||= existing_billable_instances.where(
            external_id: external_id
          ).first_or_initialize
          if @billable_instance.new_record?
            record = existing_billable_instances.find_by("details->>'ip' = ?", external_id)
            record ||= existing_billable_instances.find_by(external_id: alternate_ids)
            @billable_instance = record unless record.nil?
          end
          @billable_instance
        end

        def line_item_type
          case params[:type]
          when "firewall"
            :firewall
          end
        end

        def current_details
          billable_instance.details
        end

        def alternate_ids
          details = billable_instance.details
          [details.dig("ip"), details.dig("device_id")].compact
        end

        def existing_billable_instances
          @existing_billable_instances ||= BillableInstance.where(
            line_item_type: line_item_type, account_path: @customer.path
          )
        end

        def external_id
          Base64.decode64(params[:id])
        end

        def permitted_params
          current_details.merge(params[:details].reject { |_, v| v.blank? }.permit!)
        end

        def log_lookup!
          # Rails.logger.tagged("BillableInstanceRegistration") do
          #   Rails.logger.info "type=#{line_item_type} external_id=#{external_id}"
          # end
        end
      end
    end
  end
end
