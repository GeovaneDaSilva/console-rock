module Api
  module V1
    module Customers
      # Account devices
      class DevicesController < Api::V1::Customers::CustomersBaseController
        before_action :deleted_customer_check!
        before_action :find_or_create_egress_ip, only: [:update]

        def update
          @device = device
          new_device = !@device.persisted?
          params[:timezone] = "Australia/Adelaide" if params[:timezone] == "Etc\/GMT-9.5"
          params[:timezone] = "Australia/Adelaide" if params[:timezone] == "Etc\/GMT-10.5"

          @device.assign_attributes(device_params)
          if @device.save
            # Drain any previous instance's queued messages
            DeviceBroadcasts::Drainer.new(@device.id).call if new_device

            AccountBroadcaster.new(@customer, :device).call

            head :created
          else
            head :bad_request
          end
        rescue ActiveRecord::RecordNotUnique
          Rails.logger.tagged("API Error") do
            Rails.logger.fatal("Duplicate device registration: #{device_params.to_h.to_json}")
          end

          head :bad_request
        end

        private

        def device
          find_device
        rescue ActiveRecord::RecordNotFound
          @customer.devices.new(id: params[:id])
        end

        def find_device
          @customer.devices.find_by!(id: params[:id].downcase)
        rescue ActiveRecord::RecordNotFound
          @customer.devices.find_by!(uuid: params[:id].downcase).tap do |d|
            ::Devices::IdMigration.new(d).call
          end

          @customer.devices.find_by!(id: params[:id].downcase)
        end

        def device_params
          params.permit(
            :hostname, :ipv4_address, :mac_address, :username, :fingerprint,
            :timezone, :ipv4_subnet_mask, :platform, :family, :version, :edition,
            :architecture, :build, :release, :agent_version, :device_type
          ).merge(
            egress_ip_id: @egress_ip.id, last_connected_at: DateTime.current,
            account_path: @customer.path
          )
        end

        def find_or_create_egress_ip
          @egress_ip ||= @customer.egress_ips.find_or_create_by(ip: remote_ip)
        end

        def deleted_customer_check!
          return unless @customer.is_a?(DeletedCustomer)

          head :ok
        end
      end
    end
  end
end
