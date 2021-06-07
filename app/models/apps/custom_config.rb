module Apps
  # STI configuration for an app, scoped to account
  class CustomConfig < Config
    belongs_to :account

    def inheritance_tree
      Apps::CustomConfig.joins(:account).where(
        type: "Apps::CustomConfig", account_id: account.ancestors.select(:id),
        app: app
      ).order("accounts.path DESC")
    end
  end
end
