class TransferLegacyAppConfigs < ActiveRecord::Migration[5.2]
  def up
    AccountApp.where(disabled_at: nil).where.not(enabled_at: nil, config: {}).each do |account_app|
      Apps::AccountConfig.create(
        config:  account_app.config,
        account: account_app.account,
        app:     account_app.app
      )
    end
  end
end
