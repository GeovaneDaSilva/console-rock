class Setting < ApplicationRecord
  belongs_to :account, touch: true

  def setting_fields
    attributes.reject { |k, _v| %w[id account_id created_at].include?(k) }
  end
end

class MoveSettingsToAccountModel < ActiveRecord::Migration[5.1]
  def change
    rename_column :settings, :provider_id, :account_id

    Customer.find_each do |customer|
      next if customer.setting

      Setting.create(customer.provider.setting.setting_fields.merge(account: customer))
    end
  end
end
