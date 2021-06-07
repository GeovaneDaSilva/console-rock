module Apps
  # STI configuration for an app, scoped to device
  class DeviceConfig < Apps::Config
    belongs_to :device

    after_update :set_account_id

    def set_account_id
      account_id = device.customer_id
      update_column(:account_id, account_id)
    end

    def inheritance_tree
      Apps::AccountConfig.joins(:account).where(
        type: "Apps::AccountConfig", account_id: device.customer.self_and_ancestors.select(:id),
        app: app
      ).order("accounts.path DESC")
    end
  end
end
