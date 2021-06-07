module Apps
  # STI configuration for an app, scoped to account
  class AccountConfig < Config
    belongs_to :account

    def inheritance_tree
      Apps::AccountConfig.joins(:account).where(
        type: "Apps::AccountConfig", account_id: account.ancestors.select(:id),
        app: app
      ).order("accounts.path DESC")
    end
  end
end
