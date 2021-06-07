module DeviceMessages
  # Processes log messages sent by a device
  class Connection < Base
    def call
      broadcast_inactive_account! if device.customer.billing_account.actionable_past_due?
      update_device_connectivity! if update_device_connectivity?

      log = device.logs.create(
        payload: payload, created_at: timestamp, updated_at: timestamp
      )

      Broadcasts::Devices::Logs.new(device, log).call
      Broadcasts::Devices::Status.new(device).call

      AccountBroadcaster.new(device.customer, :device).call
      log
    end

    private

    def payload
      case @message["type"]
      when "connected"
        "Device connected"
      when "disconnected"
        "Device disconnected"
      end
    end

    def connectivity
      case @message["type"]
      when "connected"
        :online
      when "disconnected"
        :offline
      end
    end

    def update_connected!
      device.update_columns(
        connectivity:            connectivity,
        last_connected_at:       DateTime.current,
        connectivity_updated_at: DateTime.current,
        updated_at:              DateTime.current
      )
    end

    def update_disconnected!
      device.update_columns(
        connectivity:            connectivity,
        connectivity_updated_at: DateTime.current,
        updated_at:              DateTime.current
      )

      device.connectivity_logs.create(
        connected_at:    device.last_connected_at,
        disconnected_at: timestamp
      )
    end

    def update_device_connectivity!
      case connectivity
      when :online
        update_connected!
      when :offline
        update_disconnected!
      end
    end

    def update_device_connectivity?
      timestamp > device.last_connected_at
    end

    def broadcast_inactive_account!
      DeviceBroadcasts::Device.new(
        device.id,
        {
          type: "account_inactive", payload: { days: device.customer.billing_account.days_past_due }
        }.to_json,
        true
      )
    end
  end
end
